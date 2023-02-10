# team-ada-test-investigation
A place for code and stuff relating to team Ada's Friday investigation of our test suite

# For standup
## If you have to click `re-run specs` in CI, please send a note to jmax or Sonia about it.
   Please include a copy/paste of the actual failure.
   CI/branch links too.

# Things to do some Friday
## CI pipeline test data scraper (jmax)
## Test data repository/munging (jmax)
## Our tests don't use `email_spec/rspec` (should be in `rails_helper.rb`); why?
## Examine analytics specs; lots of things that add no value and things missing
   (John Skinner)

# Suspicious looking tests
## spec/features/visitors/password_recovery_spec.rb
  Uses reset_email and open_last_email in a suspicious fashion (two
  places)
## spec/features/event_disavowal_spec.rb
  Uses `open_last_email` in a possible race condition (line 137)
## spec/features/delete_account_spec.rb
  Uses `open_last_email` in a possible race condition (line 42, 125)


# Ideas and stuff
- Can we use `open_email(email)` instead of `open_last_email` more?
- spec/services/encryptions/aes_cipher_spec.rb:5 - why use random
  data?
- All specs - can we easily look for spec-embedded class definitions
  and vet them for collisions?
- `flow_session` is a hash with indifferent access in the production
  environment. Is is worth making sure all of the tests which mock it
  are also using indifferent access?

# Probably fixed
- Some unexpected test failures (From Slack conversation with Sonia):
```
    These failures look unrelated to the changes Matt was making: https://gitlab.login.gov/lg/identity-idp/-/jobs/315530
    1) Account Reset Request: Cancellation user cancels from the second email after the request has been granted cancels the request and does not delete the user
    3155     Failure/Error: open_last_email
    3156     RuntimeError:
    3157       No email has been sent!
    3158     # ./spec/features/account_reset/cancel_request_spec.rb:24:in `block (4 levels) in <top (required)>'
    3159     # ./spec/features/account_reset/cancel_request_spec.rb:22:in `block (3 levels) in <top (required)>'
    3160     # ./spec/rails_helper.rb:134:in `block (2 levels) in <top (required)>'
    3161Failures:
    3162  1) Account Reset Request: Cancellation user cancels from the second email after the request has been granted cancels the request and does not delete the user
    3163     Failure/Error: open_last_email
    3164     RuntimeError:
    3165       No email has been sent!
    3166     # ./spec/features/account_reset/cancel_request_spec.rb:24:in `block (4 levels) in <top (required)>'
    3167     # ./spec/features/account_reset/cancel_request_spec.rb:22:in `block (3 levels) in <top (required)>'
    3168     # ./spec/rails_helper.rb:134:in `block (2 levels) in <top (required)>'
```

    We think we've fixed this, but have no good way to
    confirm. Monitor CI runs to see if this is really gone.

