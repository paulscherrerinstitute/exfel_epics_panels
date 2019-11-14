;; this file contains function for generating IBFB panels

(defun medm-text-black (x y text)
  "insert text object"
  (insert (format
"text {
	object {
		x=%d
		y=%d
        width=200
		height=20
	}
	\"basic attribute\" {
		clr=14
	}
	textix=\"%s\"
    align=\"horiz. centered\"
}
" x y text)))

(defun medm-text-white (x y text)
  "insert text object"
  (insert (format
           "text {
	object {
		x=%d
		y=%d
	}
	\"basic attribute\" {
		clr=0
	}
	textix=\"%s\"
    align=\"horiz. centered\"
}
" x y text)))


;; text {
;; object {
;; x=10
;; y=213
;; width=70
;; height=15
;; }
;; "basic attribute" {
;; clr=0
;; }
;; textix="SASE 1"
;; align="horiz. right"
;; }

(defun medm-bpm-shell-command (x y bpm-name)
  "insert shell command"
  (insert (format
"\"shell command\" {
    object {
        x=%d
        y=%d
		width=85
        height=20
	}
    command[0] {
        label=\"Terminal\"
        name=\"./xfel_qt.sh %s BPM_GPAC_CAV_SMP.ui &\"
    }
    clr=14
    bclr=57
    label=\"-%s\"
}
"  x y bpm-name bpm-name)))

(defun medm-bpm-psi-shell-command (x y bpm-name)
  "insert shell command"
  (insert (format
           "\"shell command\" {
    object {
        x=%d
        y=%d
		width=85
        height=20
	}
    command[0] {
        label=\"Terminal\"
        name=\"./psi_qt.sh %s BPM_GPAC_CAV_SMP.ui &\"
    }
    clr=14
    bclr=57
    label=\"-%s\"
}
"  x y bpm-name bpm-name)))

(defun medm-bpm-serv-message (x y bpm-name host-name port-number)
  (insert (format
"\"message button\" {
object {
x=%d
y=%d
width=85
height=20
}
control {
chan=\"CAVBPM:BPM-STRING.AA\"
clr=14
bclr=57
}
label=\"%s\"
press_msg=\"%s:%d#%s\"
}
" x y bpm-name host-name port-number bpm-name)))


(defun medm-related-gpac-service (x y dev-name ipc-name)
  (insert (format 
"\"related display\" {
	object {
		x=%d
		y=%d
		width=65
		height=20
	}
	display[0] {
		label=\"BPM\"
		name=\"F_DI_FIN250_BPM_GPAC_SERVICE.adl\"
		args=\"DEV=%s\"
	}
	clr=14
	bclr=57
	label=\"-%s\"
}
" x y (upcase dev-name) (upcase ipc-name))))

(defun medm-related-xfeltim (x y dev-name)
  (insert (format
"\"related display\" {
	object {
		x=%d
		y=%d
		width=65
		height=20
	}
	display[0] {
		label=\"BPM\"
		name=\"XFELTIM.adl\"
		args=\"DEV=%s\"
	}
	clr=14
	bclr=57
	label=\"-XFELTIM\"
}
" x y (upcase dev-name))))


(defun medm-xterm-shell-command (x y host-name)
  "insert xterm shell command"
  (insert (format
           "\"shell command\" {
	object {
		x=%d
		y=%d
		width=115
		height=20
	}
	command[0] {
		label=\"Terminal\"
		name=\"xterm -T %s -bg rgb:40/A0/90 -e telnet -l root %s &\"
	}
	clr=14
	bclr=57
	label=\"-%s\"
}
" x y host-name host-name host-name)))
  




(defun medm-rectangle-red-green-status (x y dev-name)       
  (insert (format
"rectangle {
	object {
		x=%d
		y=%d
		width=5
		height=20
	}
	\"basic attribute\" {
		clr=20
	}
	\"dynamic attribute\" {
		vis=\"calc\"
		calc=\"A=0\"
		chan=\"%s:S7GPAC-STATUS\"
	}
}
rectangle {
	object {
		x=%d
		y=%d
		width=5
		height=20
	}
	\"basic attribute\" {
		clr=15
	}
	\"dynamic attribute\" {
		vis=\"calc\"
		calc=\"A=1\"
		chan=\"%s:S7GPAC-STATUS\"
	}
}
" x y (upcase dev-name) x y (upcase dev-name))))

(defun medm-rectangle-red-green-status-more (x y dev-name channel-name visibility-red visibility-green &optional width)
  (when visibility-red
    (insert (format
             "rectangle {
	object {
		x=%d
		y=%d
		width=%d
		height=20
	}
	\"basic attribute\" {
		clr=20
	}
	\"dynamic attribute\" {
		vis=\"calc\"
		calc=\"%s\"
		chan=\"%s:%s\"
	}
}
" x y (if width width 5) (upcase visibility-red) (upcase dev-name) (upcase channel-name))))
  (when visibility-green
    (insert (format
"rectangle {
	object {
		x=%d
		y=%d
		width=%d
		height=20
	}
	\"basic attribute\" {
		clr=15
	}
	\"dynamic attribute\" {
		vis=\"calc\"
		calc=\"%s\"
		chan=\"%s:%s\"
	}
}
" x y (if width width 5) (upcase visibility-green) (upcase dev-name) (upcase channel-name)))))

(defun medm-choice-button (x y dev-name channel)
  ""
  (insert (format
"\"choice button\" {
	object {
		x=%d
		y=%d
		width=55
		height=15
	}
	control {
		chan=\"%s:%s\"
		clr=14
		bclr=56
	}
	stacking=\"column\"
}
" x (+ 3 y) (upcase dev-name) (upcase channel))))

(defun medm-text-update (x y dev-name channel)
  ""
  (insert (format
"\"text update\" {
	object {
		x=%d
		y=%d
		width=45
		height=15
	}
	monitor {
		chan=\"%s:%s\"
		clr=14
		bclr=4
	}
	align=\"horiz. right\"
	limits {
	}
}
" x (+ 3 y) (upcase dev-name) (upcase channel))))

(defun medm-text-entry (x y dev-name channel)
  ""
  (insert (format
"\"text entry\" {
	object {
		x=%d
		y=%d
		width=45
		height=15
	}
	control {
		chan=\"%s:%s\"
		clr=14
		bclr=4
	}
	limits {
	}
}
" x (+ 3 y) (upcase dev-name) (upcase channel))))

(defun medm-insert-line-psi (y bpm-1-name bpm-2-name ipc-name host-name locserv-name &optional hide-gtx-status hide-bpm-id)
  ""
  (unless (equal bpm-1-name "NONE")
    (medm-bpm-psi-shell-command 90 y (concat ipc-name "-CAV1")))
  (unless (equal bpm-2-name "NONE")
    (medm-bpm-psi-shell-command 175 y (concat ipc-name "-CAV2")))
  (medm-insert-line y bpm-1-name bpm-2-name ipc-name host-name locserv-name hide-gtx-status hide-bpm-id))

(defun medm-insert-line-xfel (y bpm-1-name bpm-2-name ipc-name host-name locserv-name &optional hide-gtx-status hide-bpm-id)
  ""
  (unless (equal bpm-1-name "NONE")
    (medm-bpm-serv-message 90 y bpm-1-name host-name 51236))
  (unless (equal bpm-2-name "NONE")
    (medm-bpm-serv-message 175 y bpm-2-name host-name 51238))
  (medm-insert-line y bpm-1-name bpm-2-name ipc-name host-name locserv-name hide-gtx-status hide-bpm-id))

  
(defun medm-insert-line (y bpm-1-name bpm-2-name ipc-name host-name locserv-name &optional hide-gtx-status hide-bpm-id)
  ""
  (let ((locserv-name (if locserv-name locserv-name (if bpm-1-name bpm-1-name bpm-2-name)))
        ;; this would hide the gtx when name is not existing or is 't
        (bpm-1-gtx-hide (if bpm-1-name (when (consp hide-gtx-status) (car hide-gtx-status)) t))
        (bpm-2-gtx-hide (if bpm-2-name (when (consp hide-gtx-status) (cdr hide-gtx-status)) t))
        (bpm-1-id-hide (if bpm-1-name (when (consp hide-bpm-id) (car hide-bpm-id)) t))
        (bpm-2-id-hide (if bpm-2-name (when (consp hide-bpm-id) (cdr hide-bpm-id)) t)))

    (when (equal bpm-1-name "NONE")
      (setq bpm-1-name nil))
    (when (equal bpm-2-name "NONE")
      (setq bpm-2-name nil))

    ;; (when bpm-1-name
    ;;   (medm-bpm-serv-message 90 y bpm-1-name host-name 51236))
    ;; (when bpm-2-name
    ;;   (medm-bpm-serv-message 175 y bpm-2-name host-name 51238))
    (medm-related-gpac-service 260 y host-name ipc-name)
    (medm-rectangle-red-green-status 325 y host-name)
    (medm-related-xfeltim 330 y host-name)
    (medm-xterm-shell-command 395 y host-name)
    (medm-rectangle-red-green-status 510 y locserv-name)
    (unless bpm-1-id-hide (medm-choice-button 520 y locserv-name "BPM1-ENABLED"))
    (unless bpm-2-id-hide (medm-choice-button 580 y locserv-name "BPM2-ENABLED"))
    (unless bpm-1-gtx-hide (medm-rectangle-red-green-status-more 642 y locserv-name "COM-SFP-STATUS" "(A & 0x100000) > 0" "(A & 0x100000) = 0" 7)) ;; RXLOSS
    (unless bpm-1-gtx-hide (medm-rectangle-red-green-status-more 652 y locserv-name "BPM1-IBFB-GTX-STATUS" "(A & 0x80) > 0" "(A & 0x80) = 0" 7)) ;; RXSYNC
    (unless (or bpm-1-gtx-hide bpm-2-gtx-hide) (medm-rectangle-red-green-status-more 662 y locserv-name "BPM1-IBFB-ROUTER-STATUS" "(A & 0x02) = 0" "(A & 0x02) > 0" 7)) ;; P0 ping
    (unless (or bpm-1-gtx-hide bpm-2-gtx-hide) (medm-rectangle-red-green-status-more 672 y locserv-name "BPM1-IBFB-ROUTER-STATUS" nil "(A & 0x08) > 0" 7)) ;; P0 addressed
    (unless bpm-2-gtx-hide (medm-rectangle-red-green-status-more 690 y locserv-name "COM-SFP-STATUS" "(A & 0x10000000) > 0" "(A & 0x10000000) = 0" 7))
    (unless bpm-2-gtx-hide (medm-rectangle-red-green-status-more 700 y locserv-name "BPM2-IBFB-GTX-STATUS" "(A & 0x80) > 0" "(A & 0x80) = 0" 7))
    (unless (or bpm-1-gtx-hide bpm-2-gtx-hide) (medm-rectangle-red-green-status-more 710 y locserv-name "BPM2-IBFB-ROUTER-STATUS" "(A & 0x02) = 0" "(A & 0x02) > 0" 7))
    (unless (or bpm-1-gtx-hide bpm-2-gtx-hide) (medm-rectangle-red-green-status-more 720 y locserv-name "BPM2-IBFB-ROUTER-STATUS" nil "(A & 0x08) > 0" 7))
    ;;(unless bpm-1-id-hide (medm-text-update 640 y locserv-name "BPM1-TRG-DELAY"))
    ;;(unless bpm-2-id-hide (medm-text-update 690 y locserv-name "BPM2-TRG-DELAY"))
    (unless bpm-1-id-hide (medm-text-update 743 y locserv-name "BPM1-BPM-ID"))
    (unless bpm-2-id-hide (medm-text-update 793 y locserv-name "BPM2-BPM-ID"))
    (unless bpm-1-id-hide (medm-text-update 848 y locserv-name "BPM1-ROUTER-ENA"))
    (unless bpm-2-id-hide (medm-text-update 898 y locserv-name "BPM2-ROUTER-ENA"))
    (unless bpm-1-id-hide (medm-text-update 953 y locserv-name "BPM1-Q-THRESHOLD"))
    (unless bpm-2-id-hide (medm-text-update 1003 y locserv-name "BPM2-Q-THRESHOLD"))
    ;; (unless bpm-1-gtx-hide (medm-rectangle-red-green-status-more 1068 y locserv-name "BPM1-PING-STATUS" "(A & 0x02) = 0" "(A & 0x02) > 0"))
    ;; (unless bpm-2-gtx-hide (medm-rectangle-red-green-status-more 1073 y locserv-name "BPM2-PING-STATUS" "(A & 0x02) = 0" "(A & 0x02) > 0"))
    ;; (unless bpm-1-gtx-hide (medm-rectangle-red-green-status-more 1088 y locserv-name "BPM1-PING-STATUS" nil "(A & 0x08) > 0"))
    ;; (unless bpm-2-gtx-hide (medm-rectangle-red-green-status-more 1093 y locserv-name "BPM2-PING-STATUS" nil "(A & 0x08) > 0"))
    ))
                    
;; (defun medm-test ()
;;   "add test"
;;   (interactive)
;;   (with-temp-file "test.adl"
;;     (insert-file-contents "test_template.adl")
;;     (goto-char (point-max))
;;     (insert "\n")
;;     (let ((y-offset 40))
;;       (let ((y (+ y-offset 55)))
;;         (dolist (line ffcol-list)
;;           (medm-insert-line-xfel y (fourth line) (fifth line) (third line) (second line) (sixth line))
;;           (setq y (+ 20 y))))
;;       (let ((y (+ y-offset 85)))
;;         (dolist (line ffb-list)
;;           (medm-insert-line-xfel y (fourth line) (fifth line) (third line) (second line) (sixth line) (seventh line))
;;           (setq y (+ 20 y))))
;;       (let ((y (+ y-offset 175)))
;;         (dolist (line sa1-list)
;;           (medm-insert-line-xfel y (fourth line) (fifth line) (third line) (second line) nil)
;;           (setq y (+ 20 y))))
;;       (let ((y (+ y-offset 565)))
;;         (dolist (line sa2-list)
;;           (medm-insert-line-xfel y (fourth line) (fifth line) (third line) (second line) nil)
;;           (setq y (+ 20 y))))
;;       (let ((y (+ y-offset 955)))
;;         (dolist (line sa3-list)
;;           (medm-insert-line-xfel y (fourth line) (fifth line) (third line) (second line) nil)
;;           (setq y (+ 20 y)))))))

(defun ibfb-xfel ()
  "generate ibfb-xfel panels"
  (interactive)
  (loop
   for sase-name in '("SA1" "SA2" "SA3")
   for mbu-list-name in (list sa1-list sa2-list sa3-list)
   do
   (with-temp-file (concat "../../App/config/medm/" "IBFBCAV_" sase-name ".adl")
     (insert-file-contents "IBFBCAV_SA_template.adl")
     (goto-char (point-max))
     (insert "\n")
     (medm-text-black 445 10 (concat "IBFB BPMs SASE " sase-name))
     (medm-text-white 40 413 (concat "SASE " sase-name))
     (let ((y-offset 40))
       (let ((y (+ y-offset 55)))
         (dolist (line ffcol-list)
           (medm-insert-line-xfel y (fourth line) (fifth line) (third line) (second line) (sixth line))
           (setq y (+ 20 y))))
       (let ((y (+ y-offset 85)))
         (dolist (line ffb-list)
           (medm-insert-line-xfel y (fourth line) (fifth line) (third line) (second line) (sixth line) (seventh line) (eighth line))
           (setq y (+ 20 y))))
       (let ((y (+ y-offset 175)))
         (dolist (line mbu-list-name)
           (medm-insert-line-xfel y (fourth line) (fifth line) (third line) (second line) (sixth line))
           (setq y (+ 20 y))))))))
       

(defun ibfbcav-psi ()
  "add test"
  (interactive)
  (let ((ibfbcav-psi-list '(
                            ("210" "xfelgpac1di1899tl" "IPC1627" "BPMI-1860-TL" "BPMI-1878-TL")
                            ("235" "xfelgpac2di1899tl" "IPC1576" "BPMI-1910-TL" "BPMI-1930-TL")
                            ("255" "xfelgpac3di1899tl" "IPC1488" "BPMI-1863-TL" "BPMI-1889-TL")
                            ("275" "ipc1629"           "IPC1629" "IPC1629-IBFB" "IPC1629-IBFB")
                            ("212" "ipc1536"           "IPC1536" "IPC1536-IBFB" "IPC1536-IBFB") 

                            )))
    (with-temp-file (concat "../../App/config/medm/" "IBFBCAV_PSI.adl")
      (insert-file-contents "IBFBCAV_PSI_template.adl")
      (goto-char (point-max))
      (insert "\n")
      (let ((y-offset 40))
        (let ((y (+ y-offset 55)))
          (dolist (line ibfbcav-psi-list)
            (medm-insert-line-psi y (fourth line) (fifth line) (third line) (second line) (sixth line))
            (setq y (+ 20 y))))))))



(defun bpmsetid-test ()
  "generate list for setbpm"
  (interactive)
  (switch-to-buffer "bpmsetid-test")
  (erase-buffer)
  (let ((bpmid 50))
    (dolist (line sa1-list)
      (insert (format "%s %d %d\n" (second line) bpmid (+ 1 bpmid)))
      (setq bpmid (+ 2 bpmid))))
  (insert "\n")
  (let ((bpmid 100))
    (dolist (line sa2-list)
      (insert (format "%s %d %d\n" (second line) bpmid (+ 1 bpmid)))
      (setq bpmid (+ 2 bpmid))))
  (insert "\n")
  (let ((bpmid 150))
    (dolist (line sa3-list)
      (insert (format "%s %d %d\n" (second line) bpmid (+ 1 bpmid)))
      (setq bpmid (+ 2 bpmid)))))


