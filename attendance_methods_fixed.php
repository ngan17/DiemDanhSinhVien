public function attendByProof(Request $request)
{
    $request->validate([
        'registrationId' => 'required|integer|exists:eventregistration,id',
        'proofImage' => 'required|image|mimes:jpeg,png,jpg|max:5120' 
    ]);

    DB::beginTransaction();

    try {
        $user = auth('api')->user();
        
        $student = DB::table('student')
            ->where('userId', $user->id)
            ->first();

        if (!$student) {
            return response()->json(['message' => 'Không tìm thấy thông tin sinh viên'], 404);
        }

        $registration = DB::table('eventregistration')
            ->where('id', $request->registrationId)
            ->where('studentId', $student->id)
            ->first();

        if (!$registration) {
            return response()->json(['message' => 'Không tìm thấy đăng ký'], 404);
        }

        if ($registration->status !== 'confirmed') {
            return response()->json(['message' => 'Đăng ký chưa được duyệt'], 400);
        }

        $eventDetail = DB::table('eventdetail')
            ->where('id', $registration->eventDetailId)
            ->first();

        $schedules = json_decode($eventDetail->attendanceSchedules, true);
        
        if (empty($schedules)) {
            return response()->json(['message' => 'Sự kiện chưa được cấu hình khung giờ điểm danh'], 400);
        }

        $now = Carbon::now('Asia/Ho_Chi_Minh');
        $eventDate = Carbon::parse($eventDetail->creditDate, 'Asia/Ho_Chi_Minh')->format('Y-m-d');
        $currentDate = $now->format('Y-m-d');
        $currentTime = $now->format('H:i:s');

        if ($currentDate !== $eventDate) {
            return response()->json(['message' => 'Không đúng ngày sự kiện'], 400);
        }

        // Tìm khung giờ hợp lệ VÀ kiểm tra isAttendProof = 1
        $isInSchedule = false;
        $currentSchedule = null;
        $currentScheduleIndex = null;
        $allSchedules = [];
        
        foreach ($schedules as $index => $schedule) {
            $timeRange = $schedule['timeRange'] ?? [];
            $isAttendProof = $schedule['isAttendProof'] ?? 0;
            
            if (count($timeRange) >= 2) {
                $startTime = $timeRange[0];
                $endTime = $timeRange[1];
                
                $allSchedules[] = [
                    'index' => $index + 1,
                    'start' => $startTime,
                    'end' => $endTime,
                    'isAttendProof' => $isAttendProof
                ];
                
                if ($currentTime >= $startTime && $currentTime <= $endTime) {
                    // Kiểm tra khung giờ này có hỗ trợ điểm danh bằng minh chứng không
                    if ($isAttendProof != 1) {
                        return response()->json([
                            'message' => 'Khung giờ này không hỗ trợ điểm danh bằng minh chứng'
                        ], 400);
                    }
                    
                    // FIXED: Kiểm tra đã điểm danh ở khung giờ này chưa
                    $alreadyAttendedInThisSchedule = DB::table('eventattendance')
                        ->where('eventRegistrationId', $registration->id)
                        ->where('typeattendance', 'proof')
                        ->where('scheduleIndex', $index)
                        ->exists();

                    if ($alreadyAttendedInThisSchedule) {
                        continue; // Tìm khung giờ khác
                    }
                    
                    $isInSchedule = true;
                    $currentScheduleIndex = $index;
                    $currentSchedule = [
                        'index' => $index + 1,
                        'start' => $startTime,
                        'end' => $endTime
                    ];
                    break;
                }
            }
        }

        if (!$isInSchedule) {
            return response()->json([
                'message' => 'Không trong khung giờ điểm danh hoặc đã điểm danh bằng phương thức này ở khung giờ hiện tại',
                'currentTime' => $currentTime,
                'availableSchedules' => $allSchedules,
                'method' => 'proof'
            ], 400);
        }

        // Tính tổng số lần phải điểm danh (từ schedules)
        $totalRequired = 0;
        $hasProofInSchedules = false;
        $hasCameraIOTInSchedules = false;
        
        foreach ($schedules as $schedule) {
            if (isset($schedule['isAttendFace']) && $schedule['isAttendFace'] == 1) {
                $totalRequired++;
            }
            if (isset($schedule['isAttendProof']) && $schedule['isAttendProof'] == 1) {
                $totalRequired++;
                $hasProofInSchedules = true;
            }
            if (isset($schedule['isAttendCamera']) && $schedule['isAttendCamera'] == 1) {
                $totalRequired++;
                $hasCameraIOTInSchedules = true;
            }
            if (isset($schedule['isAttendBarcode']) && $schedule['isAttendBarcode'] == 1) {
                $totalRequired++;
            }
        }

        // FIXED: So sánh với totalRequired thay vì attendanceTimes
        $completedCount = DB::table('eventattendance')
            ->where('eventRegistrationId', $registration->id)
            ->count();

        if ($completedCount >= $totalRequired) {
            return response()->json(['message' => 'Bạn đã điểm danh đủ số lần rồi'], 400);
        }

        // Lưu ảnh vào storage
        $image = $request->file('proofImage');
        $fileName = 'proof_' . $student->id . '_' . time() . '.' . $image->getClientOriginalExtension();
        $path = $image->storeAs('attendance_proofs', $fileName, 'public');
        $storagePath = '/storage/' . $path;

        // Tạo bản ghi điểm danh proof
        $attendanceId = DB::table('eventattendance')->insertGetId([
            'eventRegistrationId' => $registration->id,
            'studentId' => $student->id,
            'proof' => $storagePath,
            'typeattendance' => 'proof',
            'scheduleIndex' => $currentScheduleIndex,
            'attend_time' => $now,
            'created_at' => $now,
            'updated_at' => $now
        ]);

        // Đếm lại sau khi thêm
        $completedCount = DB::table('eventattendance')
            ->where('eventRegistrationId', $registration->id)
            ->count();
        
        // Đánh dấu 'attended' nếu hoàn thành TẤT CẢ (vì có proof nên chờ admin duyệt)
        if ($completedCount >= $totalRequired) {
            DB::table('eventregistration')
                ->where('id', $registration->id)
                ->update([
                    'status' => 'attended',
                    'updated_at' => $now
                ]);
        }

        DB::commit();

        // Gửi thông báo cho admin và lecturer
        try {
            $event = DB::table('event')
                ->where('id', $eventDetail->eventId)
                ->first();

            $adminLecturerTokens = DB::table('user')
                ->whereIn('role', ['admin', 'lecturer'])
                ->whereNotNull('fcmToken')
                ->where('fcmToken', '!=', '')
                ->pluck('fcmToken')
                ->toArray();

            if (!empty($adminLecturerTokens)) {
                $fcmService = $this->getFCMService();
                
                if ($fcmService && $fcmService !== false) {
                    $notificationData = [
                        'type' => 'student_attendance',
                        'method' => 'proof',
                        'studentId' => (string)$student->id,
                        'studentName' => $user->name ?? '',
                        'eventId' => (string)$eventDetail->eventId,
                        'eventName' => $event->eventName ?? '',
                        'attendanceId' => (string)$attendanceId,
                        'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
                    ];

                    $fcmService->sendToMultipleDevices(
                        $adminLecturerTokens,
                        'Minh chứng điểm danh mới cần duyệt',
                        ($user->name ?? 'Sinh viên') . ' đã gửi minh chứng điểm danh cho sự kiện ' . ($event->eventName ?? ''),
                        $notificationData
                    );

                    \Log::info("Sent proof attendance notification to admin/lecturer", [
                        'method' => 'proof',
                        'studentId' => $student->id,
                        'tokens_count' => count($adminLecturerTokens)
                    ]);
                }
            }
        } catch(\Exception $e) {
            \Log::error('Lỗi gửi thông báo điểm danh: ' . $e->getMessage());
        }

        return response()->json([
            'message' => 'Gửi minh chứng thành công (lần ' . $completedCount . '/' . $totalRequired . '), chờ admin duyệt để cộng điểm',
            'data' => [
                'attendanceId' => $attendanceId,
                'proofImage' => $storagePath,
                'attendTime' => $now->toDateTimeString(),
                'method' => 'proof',
                'status' => 'attended',
                'currentSchedule' => $currentSchedule,
                'availableSchedules' => $allSchedules,
                'attendanceProgress' => [
                    'current' => $completedCount,
                    'total' => $totalRequired,
                    'remaining' => $totalRequired - $completedCount
                ]
            ]
        ], 201);

    } catch (\Exception $e) {
        DB::rollBack();
        return response()->json([
            'message' => 'Có lỗi xảy ra',
            'error' => $e->getMessage()
        ], 500);
    }
}

public function attendByFace(Request $request)
{
    $request->validate([
        'registrationId' => 'required|integer|exists:eventregistration,id',
        'studentId' => 'required|string',
        'confidence' => 'required|numeric|min:0|max:100',
        'faceImage' => 'nullable|image|mimes:jpeg,png,jpg|max:5120'
    ]);

    DB::beginTransaction();

    try {
        $user = auth('api')->user();
        
        $student = DB::table('student')
            ->where('userId', $user->id)
            ->first();

        if (!$student) {
            return response()->json([
                'success' => false,
                'message' => 'Không tìm thấy thông tin sinh viên'
            ], 404);
        }

        if ($student->id != $request->studentId) {
            return response()->json([
                'success' => false,
                'message' => 'Khuôn mặt không khớp với tài khoản đang đăng nhập'
            ], 403);
        }

        $registration = DB::table('eventregistration')
            ->where('id', $request->registrationId)
            ->where('studentId', $student->id)
            ->first();

        if (!$registration) {
            return response()->json([
                'success' => false,
                'message' => 'Không tìm thấy đăng ký'
            ], 404);
        }

        if ($registration->status !== 'confirmed') {
            return response()->json([
                'success' => false,
                'message' => 'Đăng ký chưa được duyệt'
            ], 400);
        }

        $eventDetail = DB::table('eventdetail')
            ->where('id', $registration->eventDetailId)
            ->first();

        if (!$eventDetail) {
            return response()->json([
                'success' => false,
                'message' => 'Không tìm thấy sự kiện'
            ], 404);
        }

        $schedules = json_decode($eventDetail->attendanceSchedules, true);
        
        if (empty($schedules)) {
            return response()->json([
                'success' => false,
                'message' => 'Sự kiện chưa được cấu hình khung giờ điểm danh'
            ], 400);
        }

        $now = Carbon::now('Asia/Ho_Chi_Minh');
        $eventDate = Carbon::parse($eventDetail->creditDate, 'Asia/Ho_Chi_Minh')->format('Y-m-d');
        $currentDate = $now->format('Y-m-d');
        $currentTime = $now->format('H:i:s');

        if ($currentDate !== $eventDate) {
            return response()->json([
                'success' => false,
                'message' => 'Không đúng ngày sự kiện'
            ], 400);
        }

        // Tìm khung giờ hợp lệ VÀ kiểm tra isAttendFace = 1
        $isInSchedule = false;
        $currentSchedule = null;
        $currentScheduleIndex = null;
        $allSchedules = [];
        
        foreach ($schedules as $index => $schedule) {
            $timeRange = $schedule['timeRange'] ?? [];
            $isAttendFace = $schedule['isAttendFace'] ?? 0;
            
            if (count($timeRange) >= 2) {
                $startTime = $timeRange[0];
                $endTime = $timeRange[1];
                
                $allSchedules[] = [
                    'index' => $index + 1,
                    'start' => $startTime,
                    'end' => $endTime,
                    'isAttendFace' => $isAttendFace
                ];
                
                if ($currentTime >= $startTime && $currentTime <= $endTime) {
                    // Kiểm tra khung giờ này có hỗ trợ điểm danh bằng FaceID không
                    if ($isAttendFace != 1) {
                        return response()->json([
                            'success' => false,
                            'message' => 'Khung giờ này không hỗ trợ điểm danh bằng camera sinh viên'
                        ], 400);
                    }
                    
                    // FIXED: Kiểm tra đã điểm danh ở khung giờ này chưa
                    $alreadyAttendedInThisSchedule = DB::table('eventattendance')
                        ->where('eventRegistrationId', $registration->id)
                        ->where('typeattendance', 'camera_student')
                        ->where('scheduleIndex', $index)
                        ->exists();

                    if ($alreadyAttendedInThisSchedule) {
                        continue; // Tìm khung giờ khác
                    }
                    
                    $isInSchedule = true;
                    $currentScheduleIndex = $index;
                    $currentSchedule = [
                        'index' => $index + 1,
                        'start' => $startTime,
                        'end' => $endTime
                    ];
                    break;
                }
            }
        }

        if (!$isInSchedule) {
            return response()->json([
                'success' => false,
                'message' => 'Không trong khung giờ điểm danh hoặc đã điểm danh bằng phương thức này ở khung giờ hiện tại',
                'currentTime' => $currentTime,
                'availableSchedules' => $allSchedules,
                'method' => 'camera_student'
            ], 400);
        }

        // Tính tổng số lần phải điểm danh (từ schedules)
        $totalRequired = 0;
        $hasProofInSchedules = false;
        $hasCameraIOTInSchedules = false;
        
        foreach ($schedules as $schedule) {
            if (isset($schedule['isAttendFace']) && $schedule['isAttendFace'] == 1) {
                $totalRequired++;
            }
            if (isset($schedule['isAttendProof']) && $schedule['isAttendProof'] == 1) {
                $totalRequired++;
                $hasProofInSchedules = true;
            }
            if (isset($schedule['isAttendCamera']) && $schedule['isAttendCamera'] == 1) {
                $totalRequired++;
                $hasCameraIOTInSchedules = true;
            }
            if (isset($schedule['isAttendBarcode']) && $schedule['isAttendBarcode'] == 1) {
                $totalRequired++;
            }
        }

        // FIXED: So sánh với totalRequired thay vì attendanceTimes
        $completedCount = DB::table('eventattendance')
            ->where('eventRegistrationId', $registration->id)
            ->count();

        if ($completedCount >= $totalRequired) {
            return response()->json([
                'success' => false,
                'message' => 'Bạn đã điểm danh đủ số lần'
            ], 400);
        }

        // Lưu ảnh khuôn mặt nếu có
        $faceImagePath = null;
        if ($request->hasFile('faceImage')) {
            $image = $request->file('faceImage');
            $fileName = 'face_' . $student->id . '_' . time() . '.' . $image->getClientOriginalExtension();
            $path = $image->storeAs('attendance_faces', $fileName, 'public');
            $faceImagePath = '/storage/' . $path;
        }

        $attendanceId = DB::table('eventattendance')->insertGetId([
            'eventRegistrationId' => $registration->id,
            'studentId' => $student->id,
            'proof' => $faceImagePath,
            'typeattendance' => 'camera_student',
            'scheduleIndex' => $currentScheduleIndex,
            'attend_time' => $now,
            'created_at' => $now,
            'updated_at' => $now
        ]);

        // Đếm lại sau khi thêm
        $completedCount = DB::table('eventattendance')
            ->where('eventRegistrationId', $registration->id)
            ->count();
        
        $conductScoreAdded = 0;
        
        // Chỉ cộng điểm khi hoàn thành tất cả
        if ($completedCount >= $totalRequired) {
            // Kiểm tra có proof hoặc camera_IOT trong schedules không
            if ($hasProofInSchedules || $hasCameraIOTInSchedules) {
                // Chờ admin duyệt
                DB::table('eventregistration')
                    ->where('id', $registration->id)
                    ->update([
                        'status' => 'attended',
                        'updated_at' => $now
                    ]);
            } else {
                // Cộng điểm ngay
                $this->conductScoreService->addConductScore(
                    $student->id,
                    $registration->semesterId,
                    $eventDetail->conductScore,
                    "Điểm danh sự kiện bằng camera sinh viên"
                );
                $conductScoreAdded = $eventDetail->conductScore;
                
                DB::table('eventregistration')
                    ->where('id', $registration->id)
                    ->update([
                        'status' => 'scored',
                        'updated_at' => $now
                    ]);
            }
        }

        DB::commit();

        return response()->json([
            'success' => true,
            'message' => 'Điểm danh thành công lần ' . $completedCount . '/' . $totalRequired . ($conductScoreAdded > 0 ? ' và đã cộng điểm' : ''),
            'data' => [
                'attendanceId' => $attendanceId,
                'studentId' => $student->id,
                'confidence' => $request->confidence,
                'faceImage' => $faceImagePath,
                'method' => 'camera_student',
                'currentSchedule' => $currentSchedule,
                'availableSchedules' => $allSchedules,
                'attendTime' => $now->toDateTimeString(),
                'conductScoreAdded' => $conductScoreAdded,
                'attendanceProgress' => [
                    'current' => $completedCount,
                    'total' => $totalRequired,
                    'remaining' => $totalRequired - $completedCount
                ]
            ]
        ], 201);

    } catch (\Exception $e) {
        DB::rollBack();
        return response()->json([
            'success' => false,
            'message' => 'Có lỗi xảy ra',
            'error' => $e->getMessage()
        ], 500);
    }
}

public function attendByBarcode(Request $request)
{
    try {
        $request->validate([
            'eventDetailId' => 'required|integer',
            'barcode' => 'required|string'
        ]);

        $user = auth('api')->user();
        $eventDetailId = $request->eventDetailId;
        $barcode = $request->barcode;

        if (!$user || $user->role !== 'attendant') {
            return response()->json([
                'success' => false,
                'message' => 'Bạn không có quyền điểm danh'
            ], 403);
        }

        $eventDetail = DB::table('eventdetail')
            ->join('event', 'eventdetail.eventId', '=', 'event.id')
            ->where('eventdetail.id', $eventDetailId)
            ->select('eventdetail.*', 'event.eventName', 'event.startDate', 'event.endDate')
            ->first();

        if (!$eventDetail) {
            return response()->json([
                'success' => false,
                'message' => 'Buổi sự kiện không tồn tại'
            ], 404);
        }

        $now = Carbon::now()->format('Y-m-d');
        $eventStatus = 'ended';
        
        if ($eventDetail->startDate > $now) {
            $eventStatus = 'upcoming';
        } elseif ($eventDetail->startDate <= $now && $eventDetail->endDate >= $now) {
            $eventStatus = 'ongoing';
        }

        if ($eventStatus !== 'ongoing') {
            return response()->json([
                'success' => false,
                'message' => 'Sự kiện chưa bắt đầu hoặc đã kết thúc'
            ], 400);
        }

        $student = DB::table('student')
            ->where('id', $barcode)
            ->first();

        if (!$student) {
            return response()->json([
                'success' => false,
                'message' => 'Không tìm thấy sinh viên với mã số: ' . $barcode
            ], 404);
        }

        $registration = DB::table('eventregistration')
            ->where('studentId', $student->id)
            ->where('eventDetailId', $eventDetailId)
            ->whereIn('status', ['confirmed', 'attended']) 
            ->first();

        if (!$registration) {
            $wait_confirmRegistration = DB::table('eventregistration')
                ->where('studentId', $student->id)
                ->where('eventDetailId', $eventDetailId)
                ->first();

            if ($wait_confirmRegistration && $wait_confirmRegistration->status === 'wait_confirm') {
                return response()->json([
                    'success' => false,
                    'message' => 'Đăng ký của sinh viên chưa được duyệt',
                    'studentId' => $student->id,
                    'studentName' => $student->studentName
                ], 400);
            } elseif ($wait_confirmRegistration && $wait_confirmRegistration->status === 'canceled') {
                return response()->json([
                    'success' => false,
                    'message' => 'Đăng ký của sinh viên đã bị từ chối',
                    'studentId' => $student->id,
                    'studentName' => $student->studentName
                ], 400);
            }

            return response()->json([
                'success' => false,
                'message' => 'Sinh viên chưa đăng ký buổi này',
                'studentId' => $student->id,
                'studentName' => $student->studentName
            ], 400);
        }

        $schedules = json_decode($eventDetail->attendanceSchedules, true);
        
        if (empty($schedules)) {
            return response()->json([
                'success' => false,
                'message' => 'Sự kiện chưa được cấu hình khung giờ điểm danh',
                'studentId' => $student->id,
                'studentName' => $student->studentName
            ], 400);
        }

        $now = Carbon::now('Asia/Ho_Chi_Minh');
        $eventDate = Carbon::parse($eventDetail->creditDate, 'Asia/Ho_Chi_Minh')->format('Y-m-d');
        $currentDate = $now->format('Y-m-d');
        $currentTime = $now->format('H:i:s');

        if ($currentDate !== $eventDate) {
            return response()->json([
                'success' => false,
                'message' => 'Không đúng ngày sự kiện',
                'studentId' => $student->id,
                'studentName' => $student->studentName
            ], 400);
        }

        // Tìm khung giờ hợp lệ VÀ kiểm tra isAttendBarcode = 1
        $isInSchedule = false;
        $currentSchedule = null;
        $currentScheduleIndex = null;
        $allSchedules = [];
        
        foreach ($schedules as $index => $schedule) {
            $timeRange = $schedule['timeRange'] ?? [];
            $isAttendBarcode = $schedule['isAttendBarcode'] ?? 0;
            
            if (count($timeRange) >= 2) {
                $startTime = $timeRange[0];
                $endTime = $timeRange[1];
                
                $allSchedules[] = [
                    'index' => $index + 1,
                    'start' => $startTime,
                    'end' => $endTime,
                    'isAttendBarcode' => $isAttendBarcode
                ];
                
                if ($currentTime >= $startTime && $currentTime <= $endTime) {
                    // Kiểm tra khung giờ này có hỗ trợ điểm danh bằng barcode không
                    if ($isAttendBarcode != 1) {
                        return response()->json([
                            'success' => false,
                            'message' => 'Khung giờ này không hỗ trợ điểm danh bằng barcode',
                            'studentId' => $student->id,
                            'studentName' => $student->studentName
                        ], 400);
                    }
                    
                    // FIXED: Kiểm tra đã điểm danh ở khung giờ này chưa
                    $alreadyAttendedInThisSchedule = DB::table('eventattendance')
                        ->where('eventRegistrationId', $registration->id)
                        ->where('typeattendance', 'barcode')
                        ->where('scheduleIndex', $index)
                        ->exists();

                    if ($alreadyAttendedInThisSchedule) {
                        continue; // Tìm khung giờ khác
                    }
                    
                    $isInSchedule = true;
                    $currentScheduleIndex = $index;
                    $currentSchedule = [
                        'index' => $index + 1,
                        'start' => $startTime,
                        'end' => $endTime
                    ];
                    break;
                }
            }
        }

        if (!$isInSchedule) {
            return response()->json([
                'success' => false,
                'message' => 'Không trong khung giờ điểm danh hoặc đã điểm danh bằng phương thức này ở khung giờ hiện tại',
                'currentTime' => $currentTime,
                'availableSchedules' => $allSchedules,
                'method' => 'barcode',
                'studentId' => $student->id,
                'studentName' => $student->studentName
            ], 400);
        }

        // Tính tổng số lần phải điểm danh (từ schedules)
        $totalRequired = 0;
        $hasProofInSchedules = false;
        $hasCameraIOTInSchedules = false;
        
        foreach ($schedules as $schedule) {
            if (isset($schedule['isAttendFace']) && $schedule['isAttendFace'] == 1) {
                $totalRequired++;
            }
            if (isset($schedule['isAttendProof']) && $schedule['isAttendProof'] == 1) {
                $totalRequired++;
                $hasProofInSchedules = true;
            }
            if (isset($schedule['isAttendCamera']) && $schedule['isAttendCamera'] == 1) {
                $totalRequired++;
                $hasCameraIOTInSchedules = true;
            }
            if (isset($schedule['isAttendBarcode']) && $schedule['isAttendBarcode'] == 1) {
                $totalRequired++;
            }
        }

        // FIXED: So sánh với totalRequired thay vì attendanceTimes
        $completedCount = DB::table('eventattendance')
            ->where('eventRegistrationId', $registration->id)
            ->count();

        if ($completedCount >= $totalRequired) {
            return response()->json([
                'success' => false,
                'message' => 'Sinh viên đã điểm danh đủ số lần rồi',
                'studentId' => $student->id,
                'studentName' => $student->studentName,
                'attendedTimes' => $completedCount,
                'totalTimes' => $totalRequired
            ], 400);
        }

        // Thêm bản ghi điểm danh
        $attendanceId = DB::table('eventattendance')->insertGetId([
            'eventRegistrationId' => $registration->id,
            'studentId' => $student->id,
            'typeattendance' => 'barcode',
            'scheduleIndex' => $currentScheduleIndex,
            'attend_time' => $now,
            'proof' => null,
            'created_at' => $now,
            'updated_at' => $now
        ]);

        // Đếm lại sau khi thêm
        $completedCount = DB::table('eventattendance')
            ->where('eventRegistrationId', $registration->id)
            ->count();
        
        // Chỉ cộng điểm khi hoàn thành tất cả
        if ($completedCount >= $totalRequired) {
            // Kiểm tra có proof hoặc camera_IOT trong schedules không
            if ($hasProofInSchedules || $hasCameraIOTInSchedules) {
                // Chờ admin duyệt
                DB::table('eventregistration')
                    ->where('id', $registration->id)
                    ->update([
                        'status' => 'attended',
                        'updated_at' => $now
                    ]);
            } else {
                // Cộng điểm ngay
                $conductScoreService = app(\App\Services\ConductScoreService::class);
                $conductScoreService->addConductScore(
                    $student->id,
                    $registration->semesterId,
                    $eventDetail->conductScore,
                    "Điểm danh sự kiện bằng barcode (attendant)"
                );
                
                DB::table('eventregistration')
                    ->where('id', $registration->id)
                    ->update([
                        'status' => 'scored',
                        'updated_at' => $now
                    ]);
            }
        }

        DB::table('notifications')->insert([
            'studentId' => $student->id,
            'title' => 'Điểm danh thành công',
            'content' => 'Bạn đã điểm danh thành công cho sự kiện: ' . $eventDetail->eventName,
            'created_at' => Carbon::now(),
            'updated_at' => Carbon::now(),
        ]);

        // Gửi thông báo đến thiết bị của sinh viên
        try {
            $fcmToken = DB::table('user')
                ->where('id', $student->userId)
                ->value('fcmToken');

            if ($fcmToken) {
                $fcmService = $this->getFCMService();

                if ($fcmService && $fcmService !== false) {
                    $notificationData = [
                        'type' => 'attendance_success',
                        'attendanceId' => (string)$attendanceId,
                        'eventName' => $eventDetail->eventName,
                        'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
                    ];

                    $fcmService->sendToMultipleDevices(
                        [$fcmToken],
                        'Điểm danh thành công',
                        'Bạn đã điểm danh thành công cho sự kiện: ' . $eventDetail->eventName,
                        $notificationData
                    );

                    \Log::info("FCM sent to studentId: {$student->id} for attendanceId: $attendanceId");
                } else {
                    \Log::warning('FCM Service not available, skipping push notification');
                }
            } else {
                \Log::warning("No FCM token found for studentId: {$student->id}");
            }
        } catch (\Exception $e) {
            \Log::error('Failed to send FCM notification: ' . $e->getMessage());
        }

        // Gửi thông báo cho admin và lecturer
        try {
            $studentUser = DB::table('user')
                ->where('id', $student->userId)
                ->first();

            $adminLecturerTokens = DB::table('user')
                ->whereIn('role', ['admin', 'lecturer'])
                ->whereNotNull('fcmToken')
                ->where('fcmToken', '!=', '')
                ->pluck('fcmToken')
                ->toArray();

            if (!empty($adminLecturerTokens)) {
                $fcmService = $this->getFCMService();
                
                if ($fcmService && $fcmService !== false) {
                    $notificationData = [
                        'type' => 'student_attendance',
                        'method' => 'barcode',
                        'studentId' => (string)$student->id,
                        'studentName' => $studentUser->name ?? $student->studentName,
                        'eventId' => (string)$eventDetail->eventId,
                        'eventName' => $eventDetail->eventName,
                        'attendanceId' => (string)$attendanceId,
                        'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
                    ];

                    $fcmService->sendToMultipleDevices(
                        $adminLecturerTokens,
                        'Điểm danh mới bằng barcode',
                        ($studentUser->name ?? $student->studentName) . ' đã điểm danh bằng barcode cho sự kiện ' . $eventDetail->eventName,
                        $notificationData
                    );

                    \Log::info("Sent barcode attendance notification to admin/lecturer", [
                        'method' => 'barcode',
                        'studentId' => $student->id,
                        'tokens_count' => count($adminLecturerTokens)
                    ]);
                }
            }
        } catch(\Exception $e) {
            \Log::error('Lỗi gửi thông báo điểm danh cho admin/lecturer: ' . $e->getMessage());
        }

        return response()->json([
            'success' => true,
            'message' => 'Điểm danh thành công lần ' . $completedCount . '/' . $totalRequired,
            'studentId' => $student->id,
            'studentName' => $student->studentName,
            'eventName' => $eventDetail->eventName,
            'session' => $eventDetail->session,
            'attendanceId' => $attendanceId,
            'method' => 'barcode',
            'currentSchedule' => $currentSchedule ?? null,
            'availableSchedules' => $allSchedules ?? [],
            'attendTime' => Carbon::now()->toDateTimeString(),
            'attendanceProgress' => [
                'current' => $completedCount,
                'total' => $totalRequired,
                'remaining' => $totalRequired - $completedCount
            ]
        ], 200);

    } catch (\Illuminate\Validation\ValidationException $e) {
        return response()->json([
            'success' => false,
            'message' => 'Dữ liệu không hợp lệ',
            'errors' => $e->errors()
        ], 422);
    } catch (\Exception $e) {
        return response()->json([
            'success' => false,
            'message' => 'Lỗi khi điểm danh',
            'error' => $e->getMessage()
        ], 500);
    }
}
