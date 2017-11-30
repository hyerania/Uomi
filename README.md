# Uomi

**Uomi** is a transaction management system for groups. 
Users can log bills and split the costs between others, 
and keep track of who owes whom. The application also 
helps users to settle up using common payment 
applications such as PayPal and Apple Pay.

## User Stories
--------------------

The following **priority** functionality is completed:

- [ ] Users can register an account
  - [ ] Email
  - [ ] Name
  - [ ] Password
- [ ] Users can create event groups
  - [ ] Name
  - [ ] Description
  - [ ] Members
- [ ] Users can add friends to groups by adding their ID
- [ ] Members of a group can log an expense consisting of:
  - [ ] Date
  - [ ] Category
  - [ ] Business (inferred from location if possible)
  - [ ] Description
  - [ ] Picture
  - [ ] Payer
  - [ ] Total paid
  - [ ] Contributing members
  - [ ] Division of payment
    - [ ] Equal share
    - [ ] Percentage
    - [ ] Line-Item
      - [ ] By shares
- [ ] Users can settle up per event with other members
- [ ] Users can see how much is owed them or they owe within an event
- [ ] Users can log a manual (cash) payment in addition to paying through other apps
- [ ] Users see the most recently edited events at the top of their event list page
- [ ] Users see the most recent transactions in their event transaction view
- [ ] Users can claim portions of a logged transaction according to the above payment options
- [ ] Users can submit a payment via other Services (e.g. PayPal)
  

The following **optional** features are implemented:
- [ ] When a user pays through a service they can record or the app automatically records the confirmation number
- [ ] When a user creates an event group they are assigned the group admin role
- [ ] The event group's admin can end an event to prevent additional transactions from being added
- [ ] Users can leave a group if no transactions

- [ ] Users can set an image for an event
- [ ] Users maintain a friends list
- [ ] Users can sign in with OAuth
- [ ] Users can message a group
- [ ] Members of a group can log a transaction consisting of:
  - [ ] Location (coordinates)
- [ ] Users can see how much is owed them or that they owe friends in general
- [ ] Users can ask the application to recommend a payer for a transaction
  - [ ] The recommender calculates who in the group owes the most to all other parties within the event context
  - [ ] The recommender calculates who in the group owes the most to all other parties globally
  - [ ] The recommender randomly selects a user from the pool of most-qualified candidates if there is no clear choice
  - [ ] The recommender displays a popup for the user to confirm the selection
    - [ ] the reason for selecting the candidate is displayed
    - [ ] Users can accept, reject, or re-calculate (if it's between several payers) the selection
  - [ ] The recommender prompts the users to select from the best candidates. The popup includes an option to have the recommender randomly select one of the candidates
- [ ] When a user pays through another app, a confirmation resolves the dollar amount between the parties
- [ ] When a user assigns another user to a transaction share, the other user must confirm
- [ ] Group beacons
- [ ] Users can lock a transaction to prevent edits
- [ ] Only the user that created a transaction can change the transaction
- [ ] When an admin user leaves their group, the admin role is passed to another user randomly
- [ ] An admin user can assign another user the admin role for a group

The following **additional** features are implemented:

- [ ] 


The following need to be dressed up:
- [x] Active on Events need to be replaced with date of last transaction or removed.
- [ ] TransactionsTableViewController
  - [x] Balances (Inbalances) on top of balances button.
    -[x] Color the numbers as described in BalancesTableViewController
  - [ ] Settlement should have two ParticipantViews with an arrow. (reference keynote - Slide 23)
  - [x] Update "You covered Kevin and Yerania" with actual description. (REMOVED Not necessary)
  - [x] Selecting a "Payment"/Settlement transaction should not highight it.
- [x] Update + button on EventEdit to be more style friendly. (Eric)
- [ ] BalancesTableViewController
  - [x] Change Initials to be ParticipantView
  - [ ] Add the banner for inbalances (Negative is RED, Positive is Orange, Green is 0.00)
  - [x] Change the amount to use the Uomi Formatter (Kevin)
- [x] SettlementTableViewController
  - [x] Change Initials to be ParticipantView (Custom implementation since size restriction)
  - [x] Fix "You owe" to actual text with the banner colors referenced above.
  - [x] Align buttons/labels.
  - [x] Change "Pay Back" button to "Log Payment".
  - [x] Only show "Log Payment" button whenever you are owed money.
  - [x] Update Transactions Table View below with actual transactions.
- [x] Pull to referesh on each of the tableview controllers or wherever necessary.

## Video Walkthrough

Here's a walkthrough of implemented user stories:

__

## Notes


## License

Copyright 2017 Team Uomi: Eric Gonzalez, Yerania Hernandez, Kevin J Nguyen


