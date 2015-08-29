(import [PyQt5.QtCore [QDate Qt]]
        [PyQt5.QtGui [QColor QFont QTextCharFormat
                      QTextLength QTextTableFormat]]
        [PyQt5.QtWidgets [QApplication QComboBox QDateTimeEdit
                          QHBoxLayout QLabel QMainWindow
                          QSpinBox QTextBrowser QVBoxLayout
                          QWidget]])

(defclass MainWindow [QMainWindow]
  [[--init--
    (fn [self]
      (.--init-- (super MainWindow self))

      (setv self.selectedDate (QDate.currentDate))
      (setv self.fontSize 10)
      (setv self.fontSizeLabel (QLabel "Font size:"))
      (setv self.fontSizeSpinBox (QSpinBox))
      (setv self.editor (QTextBrowser))

      (let [[centralWidget (QWidget)]
            [dateLabel (QLabel "Date:")]
            [monthCombo (QComboBox)]
            [yearEdit (QDateTimeEdit)]]
        (for [month (range 1 13)]
          (.addItem monthCombo (QDate.longMonthName month)))
        (.setDisplayFormat yearEdit "yyyy")
        (.setDateRange yearEdit
                       (QDate 1753 1 1)
                       (QDate 8000 1 1))
        (.setCurrentIndex monthCombo
                          (- (self.selectedDate.month)
                             1))
        (.setDate yearEdit self.selectedDate)
        (.setRange self.fontSizeSpinBox 1 64)
        (.setValue self.fontSizeSpinBox 10)
        (self.insertCalendar)
        (.connect monthCombo.activated self.setMonth)
        (.connect yearEdit.dateChanged self.setYear)
        (.connect self.fontSizeSpinBox.valueChanged
                  self.setFontSize)

        (setv controlsLayout (QHBoxLayout))
        (.addWidget controlsLayout dateLabel)
        (.addWidget controlsLayout monthCombo)
        (.addWidget controlsLayout yearEdit)
        (.addSpacing controlsLayout 24)
        (.addWidget controlsLayout self.fontSizeLabel)
        (.addWidget controlsLayout self.fontSizeSpinBox)
        (.addStretch controlsLayout 1)

        (setv centralLayout (QVBoxLayout))
        (.addLayout centralLayout controlsLayout)
        (.addWidget centralLayout self.editor 1)
        (.setLayout centralWidget centralLayout)
        (.setCentralWidget self centralWidget)))]

   [insertCalendar
    (fn [self]
      (.clear self.editor)
      (let [[cursor (.textCursor self.editor)]
            [date (QDate (.year self.selectedDate) (.month self.selectedDate) 1)]
            [tableFormat (QTextTableFormat)]]
        (.beginEditBlock cursor)

        (.setAlignment tableFormat Qt.AlignHCenter)
        (.setBackground tableFormat
                        (QColor "#e0e0e0"))
        (.setCellPadding tableFormat 2)
        (.setCellSpacing tableFormat 4)

        (setv constraints (* [(QTextLength QTextLength.PercentageLength 14)]
                             7))
        (.setColumnWidthConstraints tableFormat constraints)

        (setv table (.insertTable cursor 1 7 tableFormat))
        (setv frame (cursor.currentFrame))
        (setv frameFormat (frame.frameFormat))
        (.setBorder frameFormat 1)

        (setv format (cursor.charFormat))
        (.setFontPointSize format self.fontSize)

        (setv boldFormat (QTextCharFormat format))
        (.setFontWeight boldFormat QFont.Bold)

        (setv highlightedFormat (QTextCharFormat boldFormat))
        (.setBackground highlightedFormat Qt.yellow)

        (for [weekDay (range 1 8)]
          (setv cell (.cellAt table 0 (- weekDay 1)))
          (setv cellCursor (.firstCursorPosition cell))
          (.insertText cellCursor (QDate.longDayName weekDay) boldFormat))

        (.insertRows table (.rows table) 1)

        (while (= (.month date) (.month self.selectedDate))
          (setv weekDay (.dayOfWeek date))
          (setv cell (.cellAt table
                              (- (.rows table) 1)
                              (- weekDay 1)))
          (setv cellCursor (.firstCursorPosition cell))

          (if (= date (QDate.currentDate))
            (.insertText cellCursor (str (.day date)) highlightedFormat)
            (.insertText cellCursor (str (.day date)) format))

          (setv date (.addDays date 1))

          (if (and (= weekDay 7)
                   (= (.month date) (.month self.selectedDate)))
            (.insertRows table (.rows table) 1)))

        (.endEditBlock cursor)
        (.setWindowTitle self (% "Calendar for %s %d"
                                 (tuple [(QDate.longMonthName (.month self.selectedDate))
                                         (.year self.selectedDate)])))))]
   [setFontSize
    (fn [self size]
      (setv self.fontSize size)
      (.insertCalendar self))]
   
   [setMonth
    (fn [self month]
      (setv self.selectedDate (QDate (.year self.selectedDate)
                                     (+ month 1)
                                     (.day self.selectedDate)))
      (.insertCalendar self))]

   [setYear
    (fn [self date]
      (setv self.selectedDate (QDate (.year date)
                                     (.month self.selectedDate)
                                     (.day self.selectedDate)))
      (.insertCalendar self))]
   ]
  )

(defmain [&rest args]
  (let [[app (QApplication (list args))]
        [window (MainWindow)]]
    (.resize window 640 256)
    (.show window)
    (.exit sys (.exec_ app))))
