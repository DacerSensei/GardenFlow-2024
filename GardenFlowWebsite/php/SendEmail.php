<?php
// Include PHPMailer

require_once "PHPMailer/PHPMailer.php";
require_once "PHPMailer/SMTP.php";
require_once "PHPMailer/Exception.php";

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\SMTP;
use PHPMailer\PHPMailer\Exception;

// Create a new PHPMailer instance
$mail = new PHPMailer(true);

$password = $_GET["password"];
$email = $_GET["email"];

$credentialEmail = "pamantasanp@gmail.com";
$credentialPassword = "kwujqwwymwqolovi";

try {
    // Server settings
    $mail->isSMTP();  // Set mailer to use SMTP
    $mail->Host       = 'smtp.gmail.com';  // Specify your SMTP server
    $mail->SMTPAuth   = true;                 // Enable SMTP authentication
    $mail->Username   = $credentialEmail;      // SMTP username
    $mail->Password   = $credentialPassword;      // SMTP password
    $mail->SMTPSecure = 'tls';                // Enable TLS encryption; `ssl` also accepted
    $mail->Port       = 587;                  // TCP port to connect to

    // Recipients
    $mail->setFrom($credentialEmail, 'Admin Garden Monitoring System');
    $mail->addAddress($email);

    // Content
    $mail->isHTML(true);  // Set email format to HTML
    $mail->Subject = 'Your password';
    $mail->Body    = "<p>Email: " . $email . "</p>" . "<p>Password: " . $password . "</p>";
    // Send the email
    if ($mail->send()) {
        echo 'Message has been sent successfully!';
    } else {
        echo 'Message did not send!';
    }
} catch (Exception $e) {
    echo "Mailer Error: {$mail->ErrorInfo}";
}
