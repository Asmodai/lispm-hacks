;;; -*- Mode: LISP; Syntax: Common-Lisp; Package: X-SCREEN; Base: 10; Lowercase: Yes -*-
;;;
;;; This is the Emacs version of `Keyboard.lisp'.  It won't look as pretty.
;;;
;;;
;;; Symbolics keyboard scan code table
;;;
;;; This is the proposed scancode table for the Symbolics keyboard USB hack.
;;; Where possible it uses keyboard usage values taken from the USB HID
;;; usage tables v1.12.
;;;
;;; +---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+
;;; |Function |Escape   |Refresh  |Square   |Circle   |Triangle |Clear    |Suspend  |Resume   |Abort    |
;;; |(F1)     |         |(F2)     |(F3)     |(F4)     |(F5)     |(F6)     |(F7)     |(F8)     |(F9)     |
;;; |3A       |29       |3B       |3C       |3D       |3E       |3F       |40       |41       |42       |
;;; +---------+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+---------+
;;; |Network  |:   |1 ! |2 @ |3 # |4 $ |5 % |6 ^ |7 & |8 * |9 ( |0 ) |- _ |= + |` ~ |\ { || } |Help     |
;;; |(F10)    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |    |(F13)    |
;;; |43       |CB  |1E  |1F  |20  |21  |22  |23  |24  |25  |26  |27  |2D  |2E  |FF  |100 |101 |68       |
;;; +---------+----+--+-+--+-+--+-+--+-+--+-+--+-+--+-+--+-+--+-+--+-+--+-+--+-+--+-+--+-+----+---------+
;;; |Local    |Tab    |q Q |w W |e E |r R |t T |y Y |u U |i I |o O |p P |( [ |) ] |B-S |Page  |Complete |
;;; |(F11)    |       |    |    |    |    |    |    |    |    |    |    |    |    |    |(F14) |(F15)    |
;;; |(44)     |2B     |14  |1A  |08  |15  |17  |1C  |18  |0C  |12  |13  |102 |103 |4C  |69    |6A       |
;;; +---------+-------+-+--+-+--+-+--+-+--+-+--+-+--+-+--+-+--+-+--+-+--+-+--+-+--+----+-+----+---------+
;;; |Select   |Rubout   |a A |s S |d D |f F |g G |h H |j J |k K |l L |; : |' " |Return   |Line| End     |
;;; |(F12)    |         |    |    |    |    |    |    |    |    |    |    |    |         |(F16|         |
;;; |45       |2A       |04  |16  |07  |09  |0A  |0B  |0D  |0E  |0F  |33  |34  |28       |6B  |58       |
;;; +----+------+----------+----+----+----+----+----+----+----+----+----+----+------+------+------+-----+
;;; |Caps|Symbol|Shift     |z Z |x X |c C |v V |b B |n N |m M |, < |. > |/ ? |Shift |Symbol|Repeat|Mode |
;;; |    |(F17) |          |    |    |    |    |    |    |    |    |    |    |      |(F18) |(F19) |     |
;;; |39  |6C    |E1        |1D  |1B  |06  |19  |05  |11  |10  |36  |37  |38  |E5    |6D    |6E    |     |
;;; +----+----+-+--+-------+-+--+----+----+----+----+----+----+----+----+-+--+---+--+-+----+----+-+-----+
;;; |Hpr |Spr |Meta|Control  |Space                                       |Ctrl  |Meta|Spr |Hpr |Scroll |
;;; |(F20|(F21|    |         |                                            |      |    |(F22|(F23|(F24)  |
;;; |6F  |70  |E2  |E0       |2C                                          |E4    |E6  |71  |72  |73     |
;;; +----+----+----+---------+--------------------------------------------+------+----+----+----+-------+
;;;
;;; Clear = Clear-Input
;;; Caps  = Caps Lock
;;; Mode  = Mode Lock
;;; Hpr   = Hyper
;;; Spr   = Super
;;; Ctrl  = Control
;;; B-S   = Back-Space
;;;
;;; Each key is represented by a pictogram.  The upper portion of which
;;; contains the symbol as found on a Symbolics keyboard.  The middle
;;; portion contains the results of `symbol'-shifting the key
;;; (unshifted and shifted), and the lower line is the HID scan code
;;; that will be generated by the firmware.
;;;
;;; Keys in brackets (or partial brackets) represent the key codes that
;;; Windows, Linux, OSX et al will see (compared to Symbol, Function et
;;; al.)
;;;
;;; The `local' key does nothing in Genera.  All our trickery there is
;;; done via the Teensy firmware.  As far as Windows or Linux or
;;; whatever is concerned, `local' generates F11.
;;;
;;; The `Mode Lock' key is handled by the firmware, with the f-locked
;;; keycodes being the same as the cursor keys on a PC keyboard.
;;;
;;; Please note that we do not support the notion of `GUI' keys either,
;;; this is in order to prevent any host OS from doing anything
;;; unexpected. 
;;;
;;;
;;; Mode Lock
;;;
;;; When `mode lock' is pressed, the Teensy firmware will send the
;;; following values in place of `right symbol', `repeat', `right meta',
;;; `right super', `right hyper', and `scroll.' 
;;;
;;; --+----+------+------+------+-----+
;;;   |/ ? |Shift |Up    |Pg Dn |Mode |
;;;   |    |      |      |      |     |
;;;   |38  |E5    |82    |78    |     |
;;; --+-+--+---+--+-+----+----+-+-----+
;;;     |Ctrl  |Left|Dn  |Rght|Pg Dn  |
;;;     |      |    |    |    |       |
;;;     |E4    |80  |81  |79  |78     |
;;; -----------+----+----+----+-------+
;;;
;;; As well as changing those modifiers to the cursor keys/page keys,
;;; the `end' key will change from its default to the `home' (code 4A)
;;; key.
;;;
;;;
;;; The `local' key
;;;
;;; From the documentation:
;;; `This key controls local console functions on XL-family and
;;; 3600-family machines:
;;;
;;;    LOCAL-D         Makes the screen dimmer.
;;;
;;;    LOCAL-B         Makes the screen brighter.
;;;
;;;    LOCAL-Q         Makes the audio quieter.
;;;
;;;    LOCAL-L         Makes the audio louder.
;;;
;;;    LOCAL-G         Rings the bell.
;;;
;;;    LOCAL-n LOCAL-C Changes the contrast of the screen. n is a digit
;;;                    between 1 and 4. 4 is greatest contrast.
;;;
;;;
;;;    LOCAL-T         (Test Mode). Sends input from the keyboard to the
;;;                    console serial port as ASCII characters. Since
;;;                    most users do not have anything connected to the
;;;                    serial port, this effectively usurps console input.
;;;
;;;    LOCAL-O         Exits from Test Mode.
;;;
;;;    LOCAL-ABORT     Resynchronizes the console, resetting all LOCAL
;;;                    settings to their initial state.
;;;
;;;    Related Lisp functions:
;;;
;;;         tv:screen-brightness
;;;         sys:console-volume
;;;
;;;    LOCAL does not work on MacIvory or UX-family machines.'
;;;
;;; This presents a vector for some rather interesting hacks, and I am
;;; certainly game for exploiting this.  Sure, we could send `Keyboard
;;; Volume Up' and `Keyboard Volume Down' the wire to the host OS - and
;;; we sure as hell will - but we can also swiftly deal with some dead
;;; keys that most hosts won't be able to cope with.  This saves me from
;;; writing drivers.
;;;
;;; So, let the fun commence:-
;;;
;;;   LOCAL-G      - prints BEL (e.g. beep or ring bell)
;;;   LOCAL-Q      - Sends `Keyboard Volume Down' (code 81)
;;;   LOCAL-L      - Sends `Keyboard Volume Up' (code 80)
;;;   LOCAL-M      - Sends `Keyboard Mute' (code 7F)
;;;   LOCAL-\      - Sends \ or | (deals with deadkey at 100/101)
;;;   LOCAL-(      - Sends { or [  (deals with deadkey at 102)
;;;   LOCAL-)      - Sends } or ]  (deals with deadkey at 103)
;;;   ...
;;;   LOCAL-V      - Prints the firmware version.
;;;
;;; The only caveat we need to be aware of is that `local' will be
;;; passing F11 to the host by default... so we would want to do some
;;; sort of detection whereby the firmware passes F11 unless `local` is
;;; held down while another key is pressed - thus it switches from a
;;; funciton key to a modifier key, and is then handled by the firmware.
;;; This will allow us to keep `local' as a usable function key when not
;;; connected to Genera.  Although, this method might require some
;;; rather hairy code.
;;;
;;; Please remember, though, that Genera does not do anything with the
;;; Local key when it comes to a MacIvory, UX, or Virtual Lisp Machine...
;;; the functionality listed above will be provided by the Teensy
;;; firmware.
;;;
;;;
;;; Keyboard signature
;;;
;;; Here we define the keyboard signature, that is a mapping of raw scan
;;; codes to values that Genera will be able to do something with.
;;;
;;; Each mapping is a list of three elements: the scan code, the
;;; unshifted key, and the shifted key.
;;;
(define-keyboard-signature :Teensy-Symbolics 
                           (:vendor-name "Symbolics, Inc."
                            :keycode-offset 0)
  ;;
  ;; Modifier keys
  (224 :left-control         :left-control)
  (225 :left-shift           :left-shift)
  (226 :left-meta            :left-meta)
  (228 :right-control        :right-control)
  (229 :right-shift          :right-shift)
  (230 :right-meta           :right-meta)
  ;;
  ;; State keys
  (57  :caps-lock            :caps-lock)
  ;;
  ;; Function keys
  (58  :f1                   :f1)
  (59  :f2                   :f2)
  (60  :f3                   :f3)
  (61  :f4                   :f4)
  (62  :f5                   :f5)
  (63  :f6                   :f6)
  (64  :f7                   :f7)
  (65  :f8                   :f8)
  (66  :f9                   :f9)
  (67  :f10                  :f10)
  (68  :f11                  :f11)
  (69  :f12                  :f12)
  (104 :f13                  :f13)
  (105 :f14                  :f14)
  (106 :f15                  :f15)
  (107 :f16                  :f16)
  (108 :f17                  :f17)
  (109 :f18                  :f18)
  (110 :f19                  :f19)
  (111 :f20                  :f20)
  (112 :f21                  :f21)
  (113 :f22                  :f22)
  (114 :f23                  :f23)
  (115 :f24                  :f24)
  ;;
  ;; Alphabetic keys
  (4   :latin-small-letter-a :latin-capital-letter-a)
  (5   :latin-small-letter-b :latin-capital-letter-b)
  (6   :latin-small-letter-c :latin-capital-letter-c)
  (7   :latin-small-letter-d :latin-capital-letter-d)
  (8   :latin-small-letter-e :latin-capital-letter-e)
  (9   :latin-small-letter-f :latin-capital-letter-f)
  (10  :latin-small-letter-g :latin-capital-letter-g)
  (11  :latin-small-letter-h :latin-capital-letter-h)
  (12  :latin-small-letter-i :latin-capital-letter-i)
  (13  :latin-small-letter-j :latin-capital-letter-j)
  (14  :latin-small-letter-k :latin-capital-letter-k)
  (15  :latin-small-letter-l :latin-capital-letter-l)
  (16  :latin-small-letter-m :latin-capital-letter-m)
  (17  :latin-small-letter-n :latin-capital-letter-n)
  (18  :latin-small-letter-o :latin-capital-letter-o)
  (19  :latin-small-letter-p :latin-capital-letter-p)
  (20  :latin-small-letter-q :latin-capital-letter-q)
  (21  :latin-small-letter-r :latin-capital-letter-r)
  (22  :latin-small-letter-s :latin-capital-letter-s)
  (23  :latin-small-letter-t :latin-capital-letter-t)
  (24  :latin-small-letter-u :latin-capital-letter-u)
  (25  :latin-small-letter-v :latin-capital-letter-v)
  (26  :latin-small-letter-w :latin-capital-letter-w)
  (27  :latin-small-letter-x :latin-capital-letter-X)
  (28  :latin-small-letter-y :latin-capital-letter-y)
  (29  :latin-small-letter-z :latin-capital-letter-z)
  ;;
  ;; Numeric keys
  (30  :digit-one            :exclamation-point)
  (31  :digit-two            :commercial-at)
  (32  :digit-three          :number-sign)
  (33  :digit-four           :dollar-sign)
  (34  :digit-five           :percent-sign)
  (35  :digit-six            :circumflex-accent)
  (36  :digit-seven          :ampersand)
  (37  :digit-eight          :asterisk)
  (38  :digit-nine           :left-parenthesis)
  (39  :digit-zero           :right-parenthesis)
  ;;
  ;; Symbol keys
  (45  :hyphen               :low-line)
  (46  :equals-sign          :plus-sign)
  (203 :colon                :colon)
  ;;
  ;; Cursor et al
  (40  :return               :return)
  (41  :escape               :escape)
  (42  :delete               :delete)
  (43  :tab                  :tab)
  (44  :space                :space)
  (74  :home                 :home)
  (75  :prior                :prior)
  (76  :backspace            :backspace)
  (78  :next                 :next)
  (79  :right                :right)
  (80  :left                 :left)
  (81  :down                 :down)
  (82  :up                   :up)
  (88  :end                  :end)
  ;;
  ;; Keys with glyphs that do not map to standard PC keyboard scan
  ;; codes.
  (255 :grave-accent         :tilde)
  (256 :reverse-solidus      :left-curly-bracket)
  (257 :vertical-line        :right-curly-bracket)
  (258 :left-parenthesis     :left-square-bracket)
  (259 :right-parenthesis    :right-square-bracket))

;;;
;;; Keyboard mapping
;;;
;;; Here we map the above-defined keyboard scan codes to functions.
;;;
;;; You are free to add any mappings that you desire to this.  As an
;;; example of what is capable, please see:
;;;
;;;   HOST:/var/lib/symbolics/sys.sct/x11/screen/keyboards.lisp
;;;
;;; To view the current mappings used by the VLM X display, use:
;;;
;;;   Show X Keyboard Mapping
;;;
(define-keyboard-mapping :Teensy-Symbolics
                         (:leds ((1 :caps-lock)))
  ;;
  ;; The escape key maps straight
  (:escape         #\Escape)
  ;;
  ;; F1 through F24 hold the function keys as well as symbol, hyper and
  ;; super.
  (:f1             #\Function)
  (:f2             #\Refresh)
  (:f3             #\Square)
  (:f4             #\Circle)
  (:f5             #\Triangle)
  (:f6             #\Clear-Input)
  (:f7             #\Suspend)
  (:f8             #\Resume)
  (:f9             #\Abort)
  (:f10            #\Network)
  (:f12            #\Select)
  (:f13            #\Help)
  (:f14            #\Page)
  (:f15            #\Complete)
  (:f16            #\Line)
  (:f17            :left-symbol)
  (:f18            :right-symbol)
  (:f19            #\Repeat)
  (:f20            :left-hyper)
  (:f21            :left-super)
  (:f22            :right-super)
  (:f23            :right-hyper)
  (:f24            #\Scroll)
  ;;
  ;; Editing
  (:delete         #\Rubout)
  (:backspace      #\Backspace)
  (:end            #\End)
  ;;
  ;; Cursor positioning
  (:home           #\Keyboard:Home)
  (:up             #\Keyboard:Up)
  (:left           #\Keyboard:Left)
  (:right          #\Keyboard:Right)
  (:down           #\Keyboard:Down)
  (:next           #\Scroll)
  (:prior          #\Keyboard:Back-Scroll))

;;;
;;; ------------------------------------------------------------------
;;;
;;; `kbdlabel-symbolics' Symbolics adaptor scan code table
;;;
;;; This table is based on the `kdblabel' firmware for a Symbolics
;;; keyboard designed by Alexander Kurz and Hans Hubner.
;;;
;;; +---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+
;;; |Function |Escape   |Refresh  |Square   |Circle   |Triangle |Clear    |Suspend  |Resume   |Abort    |
;;; |F3       |Escape   |KP0      |KP4      |KP3      |KP2      |F10      |F4       |F5       |F6       |
;;; +---------+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+---------+
;;; |Network  |:   |1 ! |2 @ |3 # |4 $ |5 % |6 ^ |7 & |8 * |9 ( |0 ) |- _ |= + |` ~ |\ { || } |Help     |
;;; |F2       |KP* |1   |2   |3   |4   |5   |6   |7   |8   |9   |0   |-   |=   |`   |\   |KP- |F12      |
;;; +---------+----+--+-+--+-+--+-+--+-+--+-+--+-+--+-+--+-+--+-+--+-+--+-+--+-+--+-+--+-+----+---------+
;;; |Local    |Tab    |q Q |w W |e E |r R |t T |y Y |u U |i I |o O |p P |( [ |) ] |B-S |Page  |Complete |
;;; |`Windows'|Tab    |q   |w   |e   |r   |t   |y   |u   |i   |o   |p   |[   |]   |B-S |KP6   |F11      |
;;; +---------+-------+-+--+-+--+-+--+-+--+-+--+-+--+-+--+-+--+-+--+-+--+-+--+-+--+----+-+----+---------+
;;; |Select   |Rubout   |a A |s S |d D |f F |g G |h H |j J |k K |l L |; : |' " |Return   |Line| End     |
;;; |F1       |Del      |a   |s   |d   |f   |g   |h   |j   |k   |l   |;   |'   |Return   |KP7 |KP1      |
;;; +----+------+----------+----+----+----+----+----+----+----+----+----+----+------+------+------+-----+
;;; |Caps|Symbol|Shift     |z Z |x X |c C |v V |b B |n N |m M |, < |. > |/ ? |Shift |Symbol|Repeat|Mode |
;;; |    |KP8   |lShift    |z   |x   |c   |v   |b   |n   |m   |,   |.   |/   |rShift|KP5   |KP/   |     |
;;; +----+----+-+--+-------+-+--+----+----+----+----+----+----+----+----+-+--+---+--+-+----+----+-+-----+
;;; |Hpr |Spr |Meta|Control  |Space                                       |Ctrl  |Meta|Spr |Hpr |Scroll |
;;; |F8  |F7  |lAlt|lCtrl    |Space                                       |rCtrl |AltG|KP. |KP+ |F9     |
;;; +----+----+----+---------+--------------------------------------------+------+----+----+----+-------+
;;;
;;; Each key is represented by a pictogram.  The upper half of the
;;; pictogram contains the keys as printed on a Symbolics keyboard, with
;;; the lower half representing keys as seen by the host.
;;;
;;; The `kbdlabel' firmware does not do anything seriously tricky with
;;; the keyboard beyond mapping Symbolics keys to regular 104-key PC
;;; keyboard keys.
;;;
;;;
;;; Mode Lock
;;;
;;; When `mode lock' is pressed, the Teensy firmware will send the
;;; following values in place of `right symbol', `repeat', `right meta',
;;; `right super', `right hyper', and `scroll.' 
;;;
;;; --+----+------+------+------+-----+
;;;   |/ ? |Shift |Symbol|Repeat|Mode |
;;;   |    |      |Up    |Pg Up |     |
;;; --+-+--+---+--+-+----+----+-+-----+
;;;     |Ctrl  |Meta|Supr|Hypr|Scroll |
;;;     |      |Lt  |Dn  |Rt  |Pg Dn  |
;;; -----------+----+----+----+-------+
;;;
;;; As well as changing those modifiers to the cursor keys/page keys,
;;; the `complete' key will change from its default to the `home' and
;;; the `end' key will change from its default to 'end'.
;;;
;;;
;;; The `local' key
;;;
;;; The `kbdlabel' firmware will perform special actions when the
;;; `local' key is used as a modifier:
;;;
;;;   LOCAL-B      - boots the firmware into the boot loader so that it
;;;                  preprogrammed through USB by the host.
;;;
;;;   LOCAL-V      - sends the Subversion revision number of the
;;;                  firmware to the host.
;;;
;;;
;;; Keyboard signature
;;;
;;; We can just run with the defaults here, there's nothing special we
;;; need to assign.
(define-keyboard-signature :kbdlabel-symbolics
                           (:vendor-name "Symbolics, Inc."
                            :keycode-offset0))

;;;
;;; Keyboard mapping
;;;
;;; Here we map the various keyboard scan codes to functions.
;;;
;;; You are free to add any mappings that you desire to this.  As an
;;; example of what is capable, please see:
;;;
;;;   HOST:/var/lib/symbolics/sys.sct/x11/screen/keyboards.lisp
;;;
;;; To view the current mappings used by the VLM X display, use:
;;;
;;;   Show X Keyboard Mapping
;;;
(define-keyboard-mapping :kbdlabel-symbolics
                         (:lets ((1 :caps-lock)))
  ;;
  ;; The escape key maps straight.
  (:escape                     #\Escape)
  ;;
  ;; F1 through F12 hold most of the function keys as well as super and symbol
  (:f1                         #\Select)
  (:f2                         #\Network)
  (:f3                         #\Function)
  (:f4                         #\Suspend)
  (:f5                         #\Resume)
  (:f6                         #\Abort)
  (:f7                         :left-super)
  (:f8                         :left-symbol)
  (:f9                         #\Scroll)
  (:f10                        #\Clear-Input)
  (:f11                        #\Complete)
  (:f12                        #\Help)
  ;;
  ;; Most other functionality is mapped to the numeric keypad.
  (:keypad-digit-zero          #\Refresh)
  (:keypad-digit-one           #\End)
  (:keypad-digit-two           #\Triangle)
  (:keypad-digit-three         #\Circle)
  (:keypad-digit-four          #\Square)
  (:keypad-digit-five          :right-symbol)
  (:keypad-digit-six           #\Page)
  (:keypad-digit-seven         #\Line)
  (:keypad-digit-eight         :left-symbol)
  (:keypad-plus-sign           :right-hyper)
  (:keypad-minus-sign          :vertical-line :right-curly-brace)
  (:keypad-multiplication-sign :colon)
  (:keypad-division-sign       #\Repeat)
  (:keypad-decimal-point       :right-super)
  ;;
  ;; Delete and backspace
  (:delete                     #\Backspace)
  (:backspace                  #\Rubout)
  ;;
  ;; Cursor keys
  (:up                         #\Keyboard:Up)
  (:down                       #\Keyboard:Down)
  (:left                       #\Keyboard:Left)
  (:right                      #\Keyboard:Right)
  ;;
  ;; Edit keys
  (:home                       #\Keyboard:Home)
  (:next                       #\Scroll)
  (:prior                      #\Keyboard:Back-Scroll)
  (:end                        #\End)
  ;;
  ;; Catch meta keys
  (:left-alt                   :left-meta)
  (:right-alt                  :right-meta)
  (65513                       :left-meta)
  (65027                       :right-meta)
  ;;
  ;; I have not had much luck with caps lock, but I'll add it here
  ;; nonetheless.
  (:caps-lock                  :caps-lock))

;;;
;;; If one requires backspace/delete to be mapped to PC-style keyboards,
;;; then the following code in lispm-init.lisp will work:
#||

;;; Swap backspace and rubout
(defun swap-backspace-and-rubout (&optional (screen tv::main-screen))
  (let* ((table (sys::keyboard-keyboard-table
                  (si::symeval-in-instance
                    (scl::send screen :console)
                    'cli::keyboard)))
         (table-vector (cl-user::make-array 
                         (apply '* (array-dimensions table))
                         :element-type (cl-user::array-element-type
                                         table)
                         :displaced-to table))
         (rubout-positions
           (future-common-lisp:loop with target =
                                      (si:standardize-keyboard-mapping
                                        #\rubout t)
                                    for x across table-vector
                                    for pos from 0
                                    when (eql x target)
                                      collect pos))
         (backspace-positions
           (future-common-lisp:loop with target =
                                      (si:standardize-keyboard-mapping 
                                        #\backspace t)
                                    for x across table-vector
                                    for pos from 0
                                    when (eql x target)
                                      collect pos)))
    (future-common-lisp:loop for rubout-position in rubout-positions
                             for backspace-position in
                                 backspace-positions
                             do (global::swapf
                                  (aref table-vector
                                        rubout-position)
                                  (aref table-vector
                                        backspace-position)))))

;;; Initialize a modern PC keyboard for VLM
;;;
;;; Change `:name-of-keyboard-mapping' to the mapping of your choice,
;;; e.g. :kbdlabel-symbolics
;;;
(defun init-vlm-keyboard ()
  (x-screen::console-set-keyboard-type
    (send (x-screen::default-x-screen) :console) :name-of-keyboard-mapping)
  (when (yes-or-no-p "Swap backspace and rubout? ")
    (swap-backspace-and-rubout)))

;;; At the end of your init, call this:
(init-vlm-keyboard)

||#
;;;
;;; Note, though, that the above functions do not go inside a
;;; `login-forms' form.  Also note that this file will have to be
;;; compiled and loaded for the keyboard mappings to be recognised.  It
;;; is advisable that one loads this file in and saves a world image.
;;;
;;; EOF
