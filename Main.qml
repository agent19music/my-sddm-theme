import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import QtQuick.Window 2.15
import SddmComponents 2.0

Rectangle {
    id: root
    width: Screen.width || 1920
    height: Screen.height || 1080
    color: "#000000"
    
    // Apple-style design system
    readonly property color textPrimary: "#FFFFFF"
    readonly property color murder: "#a31621"
    readonly property color textSecondary: Qt.rgba(255, 255, 255, 0.9)
    readonly property color textTertiary: Qt.rgba(255, 255, 255, 0.6)
    readonly property string systemFont: "SF Pro Display, -apple-system, Helvetica Neue, sans-serif"
    readonly property int animDuration: 350
    
    property bool isAuthenticating: false
    property int failedAttempts: 0
    
    Connections {
        target: sddm
        
        function onLoginSucceeded() {
            isAuthenticating = false
        }
        
        function onLoginFailed() {
            isAuthenticating = false
            passwordField.text = ""
            failedAttempts++
            shakeAnimation.start()
            errorMessage.opacity = 1
            errorTimer.restart()
        }
    }
    
    // Beautiful blurred background - Apple style
    Item {
        anchors.fill: parent
        
        // Wallpaper
        Image {
            id: wallpaper
            anchors.fill: parent
            source: "assets/darkcityariel.png"
            fillMode: Image.PreserveAspectCrop
            smooth: true
            visible: false
        }
        
        // High-quality blur
        GaussianBlur {
            id: blurLayer1
            anchors.fill: parent
            source: wallpaper
            radius: 48
            samples: 97
            visible: false
        }
        
        GaussianBlur {
            anchors.fill: parent
            source: blurLayer1
            radius: 48
            samples: 97
        }
        
        // Subtle dark overlay
        Rectangle {
            anchors.fill: parent
            color: "#000000"
            opacity: 0.4
        }
    }
    
    
    // Clean, minimal login area - no card, just content
    Column {
        id: loginContainer
        anchors.centerIn: parent
        spacing: 40
            
        // Time display
        Text {
            id: timeText
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatTime(new Date(), "h:mm")
            color: textPrimary
            font.pixelSize: 96
            font.family: systemFont
            font.weight: Font.Bold
            font.letterSpacing: -3
            antialiasing: true
        }
        
        // User avatar - clean circle
        Item {
            width: 100
            height: 100
            anchors.horizontalCenter: parent.horizontalCenter
            
            Image {
                id: avatarImage
                anchors.fill: parent
                source: "assets/ronaldo-shadow.jpg"
                fillMode: Image.PreserveAspectCrop
                smooth: true
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: avatarImage.width
                        height: avatarImage.height
                        radius: width / 2
                    }
                }
            }
        }
        
        // Japanese greeting
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "愛してる、一秒一秒、毎分、毎時間、毎日"
            color: textSecondary
            font.pixelSize: 18
            font.family: systemFont
            font.weight: Font.Light
            antialiasing: true
        }
        
        // Clean password field - no borders, just blur background
        Item {
            width: 280
            height: 44
            anchors.horizontalCenter: parent.horizontalCenter
            
            // Blur background
            Rectangle {
                anchors.fill: parent
                radius: 22
                color: Qt.rgba(255, 255, 255, 0.15)
            }
            
            TextField {
                id: passwordField
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                echoMode: TextInput.Password
                placeholderText: "Enter Password"
                font.pixelSize: 14
                font.family: systemFont
                font.letterSpacing: 1
                color: textPrimary
                placeholderTextColor: textTertiary
                horizontalAlignment: TextInput.AlignHCenter
                verticalAlignment: TextInput.AlignVCenter
                selectByMouse: true
                passwordCharacter: "●"
                
                background: Rectangle {
                    color: "transparent"
                }
                
                Keys.onReturnPressed: {
                    if (text.length > 0 && !isAuthenticating) {
                        isAuthenticating = true
                        // Use last session or default to first available session
                        var sessionIndex = sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
                        var username = userModel.lastUser || "uzski"
                        sddm.login(username, passwordField.text, sessionIndex)
                    }
                }
                
                onTextChanged: {
                    if (errorMessage.opacity > 0) {
                        errorMessage.opacity = 0
                    }
                }
            }
        }
        
        // Error message - subtle
        Text {
            id: errorMessage
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Incorrect password"
            color: Qt.rgba(255, 255, 255, 0.7)
            font.pixelSize: 12
            font.family: systemFont
            opacity: 0
            
            Behavior on opacity {
                NumberAnimation { duration: animDuration }
            }
            
            Timer {
                id: errorTimer
                interval: 3000
                onTriggered: errorMessage.opacity = 0
            }
        }
        
    }
    
    // Subtle shake animation
    SequentialAnimation {
        id: shakeAnimation
        NumberAnimation {
            target: loginContainer
            property: "x"
            from: loginContainer.x
            to: loginContainer.x - 8
            duration: 60
        }
        NumberAnimation {
            target: loginContainer
            property: "x"
            to: loginContainer.x + 8
            duration: 60
        }
        NumberAnimation {
            target: loginContainer
            property: "x"
            to: loginContainer.x - 8
            duration: 60
        }
        NumberAnimation {
            target: loginContainer
            property: "x"
            to: loginContainer.x
            duration: 60
        }
    }
    
    
    // Clock update timer
    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: {
            timeText.text = Qt.formatTime(new Date(), "h:mm")
        }
    }
    
    Component.onCompleted: {
        passwordField.forceActiveFocus()
    }
}
