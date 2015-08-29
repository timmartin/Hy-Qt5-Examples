(import [PyQt5.QtWidgets [QApplication QComboBox QDialog
                          QDialogButtonBox QFormLayout
                          QGridLayout QGroupBox QHBoxLayout
                          QLabel QLineEdit QMenu QMenuBar
                          QPushButton QSpinBox QTextEdit
                          QVBoxLayout]])

(defclass Dialog [QDialog]
  [[NumGridRows 3]
   [NumButtons 4]

   [--init--
    (fn [self]
      (.--init-- (super Dialog self))

      (.createMenu self)
      (.createHorizontalGroupBox self)
      (.createGridGroupBox self)
      (.createFormGroupBox self)

      (setv bigEditor (QTextEdit))
      (.setPlainText bigEditor
                     "This widget takes up all the remaining space in the top-level layout")
      
      (setv buttonBox
            (QDialogButtonBox (| QDialogButtonBox.Ok
                                 QDialogButtonBox.Cancel)))
      (.connect buttonBox.accepted self.accept)
      (.connect buttonBox.rejected self.reject)
      
      (setv mainLayout (QVBoxLayout))
      (.setMenuBar mainLayout self.menuBar)
      (.addWidget mainLayout self.horizontalGroupBox)
      (.addWidget mainLayout self.gridGroupBox)
      (.addWidget mainLayout self.formGroupBox)
      (.addWidget mainLayout bigEditor)
      (.addWidget mainLayout buttonBox)
      (.setLayout self mainLayout)

      (.setWindowTitle self "Basic Layouts"))]

   [createMenu
    (fn [self]
      (setv self.menuBar (QMenuBar))
      (setv self.fileMenu (QMenu "&File" self))
      (setv self.exitAction (.addAction self.fileMenu "E&xit"))
      (.addMenu self.menuBar self.fileMenu)
      
      (.connect self.exitAction.triggered self.accept))]

   [createHorizontalGroupBox
    (fn [self]
      (setv self.horizontalGroupBox (QGroupBox "Horizontal Layout"))
      (setv layout (QHBoxLayout))
      (for [i (range Dialog.NumButtons)]
        (setv button (QPushButton (% "Button %d" (+ i 1))))
        (.addWidget layout button))
      (.setLayout self.horizontalGroupBox layout))]

   [createGridGroupBox
    (fn [self]
      (setv self.gridGroupBox (QGroupBox "Grid Layout"))
      (setv layout (QGridLayout))

      (for [i (range Dialog.NumGridRows)]
        (setv label (QLabel (% "Line %d:" (+ i 1))))
        (setv lineEdit (QLineEdit))
        (.addWidget layout label (+ i 1) 0)
        (.addWidget layout lineEdit (+ i 1) 1))

      (setv self.smallEditor (QTextEdit))
      (.setPlainText self.smallEditor
                     "This widget takes up about two thirds of the grid layout")

      (.addWidget layout self.smallEditor 0 2 4 1)

      (.setColumnStretch layout 1 10)
      (.setColumnStretch layout 2 20)
      (.setLayout self.gridGroupBox layout))]

   [createFormGroupBox
    (fn [self]
      (setv self.formGroupBox (QGroupBox "FormLayout"))
      (let [[layout (QFormLayout)]]
        (.addRow layout (QLabel "Line 1:") (QLineEdit))
        (.addRow layout (QLabel "Line 2, long text:") (QComboBox))
        (.addRow layout (QLabel "Line 3:") (QSpinBox))
        (.setLayout self.formGroupBox layout)))]
   
   ])

(defmain [&rest args]
  (let [[app (QApplication (list args))]
        [dialog (Dialog)]]
    (.exit sys (.exec_ dialog))))
