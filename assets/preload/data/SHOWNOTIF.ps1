[void] [System.Reflection.Assembly]::LoadWithPartialName("TGCI")

$objNotifyIcon = New-Object System.Windows.Forms.NotifyIcon

$objNotifyIcon.Icon = [System.Drawing.SystemIcons]::Information
$objNotifyIcon.BalloonTipIcon = "Error" 
$objNotifyIcon.BalloonTipText = "TOO LATE ROSEBLOOM TOO LATE ROSEBLOOM TOO LATE ROSEBLOOM TOO LATE ROSEBLOOM TOO LATE ROSEBLOOM TOO LATE ROSEBLOOM TOO LATE ROSEBLOOM TOO LATE ROSEBLOOM TOO LATE ROSEBLOOM" 
$objNotifyIcon.BalloonTipTitle = "MR. Z"
$objNotifyIcon.Visible = $True

$objNotifyIcon.ShowBalloonTip(10000)