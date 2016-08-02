//
//  Message.h
//  Pulse
//

#ifndef Pulse_Message_h
#define Pulse_Message_h

// General
#define INCORRECTOLDPASS @"Incorrect old password."
#define SERVER_ERROR @"That's our bad. Please try again later."
#define LOGIN_ERROR  @"Unable to login with provided credentials."
#define NETWORK_UNAVAILABLE  @"Please check your network connection."

// Sign in
#define USER_NOTREGISTERED @"The username or password may be incorrect."
#define INCORRECT_PASSWORD @"This password is not correct for the desired account."

// Sign up
#define INVALID_EMAIL @"Please enter a valid email address."
#define EMPTY_NAME @"Please enter your name."
#define EMPTY_EMAIL @"Please enter your email."
#define EMPTY_PASSWORD @"Please enter your password."
#define EMPTY_CNF_PASSWORD @"Please confirm your password."
#define EMAIL_EXISTS @"This email is already associated with an account."
#define SIGNUP_SUCCESS @"Thank you for signing up on Pulse!"

// Forgot Password
#define EMPTY_OLD_PASSWORD @"Please enter your old password."
#define EMPTY_NEW_PASSWORD @"Please enter your new password."
#define EMPTY_CNF_NEW_PASSWORD @"Please confirm your password."
#define PASS_MIN_LEGTH @"Password must be longer than 5 characters."
#define PASS_SAME @"Your old password and new password must be different."
#define PASS_MISMATCH @"The passwords entered do not match."
#define PASS_SUCCESS @"Your password has been reset successfully."
#define PASS_FAILURE @"This email does not exists in our systems."
#define PASS_SENT @"A password reset email has been sent to you."

// Change Password
#define CHANGE_PASS_SUCCESS @"Your password has been updated successfully."
#define CHANGE_PASS_MISMATCH @"Incorrect old password."

#endif
