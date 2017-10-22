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
- [ ] Users can create event groups
- [ ] Users can add friends to groups by adding their ID
- [ ] Users can opt out of a group if no transactions
- [ ] Members of a group can log an expense consisting of:
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
- [ ] Users can see how is owed them or they owe within an event
- [ ] Users can submit a payment via other Services (e.g. PayPal)
- [ ] When a user pays through a service they can record or the app automatically records the confirmation number
- [ ] Users can log a manual (cash) payment in addition to paying through other apps
- [ ] Users see the most recently edited events at the top of their event list page
- [ ] Users see the most recent transactions in their event transaction view
- [ ] Users can claim portions of a logged transaction according to the above payment options
- [ ] The event group's admin can end an event to prevent additional transactions from being added
- [ ] When a user creates an event group they are assigned the group admin role
- [ ] When an admin user leaves their group, the admin role is passed to another user randomly
- [ ] An admin user can assign another user the admin role for a group
  

The following **optional** features are implemented:

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

The following **additional** features are implemented:

- [ ] 



## Video Walkthrough 

Here's a walkthrough of implemented user stories:

__

## Notes


## License

Copyright 2017 Team Uomi: Eric Gonzalez, Yerania Hernandez, Kevin J Nguyen


