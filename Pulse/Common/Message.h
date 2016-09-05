//
//  Message.h
//  Pulse
//

#ifndef Pulse_Message_h
#define Pulse_Message_h

// General
#define INCORRECTOLDPASS @"Incorrect old password."
#define SERVER_ERROR @"Server error. Please try again later."
#define LOGIN_ERROR  @"Unable to login with provided credentials."
#define NETWORK_UNAVAILABLE  @"Please check your network connection."
#define BLOCK_USER @"You have blocked that user."

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

// Forgot password
#define EMPTY_OLD_PASSWORD @"Please enter your old password."
#define EMPTY_NEW_PASSWORD @"Please enter your new password."
#define EMPTY_CNF_NEW_PASSWORD @"Please confirm your password."
#define PASS_MIN_LEGTH @"Password must be longer than 5 characters."
#define PASS_SAME @"Your old password and new password must be different."
#define PASS_MISMATCH @"The passwords entered do not match."
#define PASS_SUCCESS @"Your password has been reset successfully."
#define PASS_FAILURE @"This email does not exists in our systems."
#define PASS_SENT @"A password reset email has been sent to you."

// Change password
#define CHANGE_PASS_SUCCESS @"Your password has been updated successfully."
#define CHANGE_PASS_MISMATCH @"Incorrect old password."

// Create party
#define EMPTY_PARTY_NAME @"Please enter a name for this party first."
#define EMPTY_PARTY_ADDRESS @"Please enter the address for the party."
#define EMPTY_MONTH @"Please enter the starting month."
#define EMPTY_DAY @"Please enter the starting day."
#define EMPTY_START_TIME @"Please enter the start time."
#define EMPTY_END_TIME @"Please enter the end time."
#define INVALID_MONTH @"Please enter a valid month."
#define INVALID_DAY @"Please enter a valid day."

#endif
