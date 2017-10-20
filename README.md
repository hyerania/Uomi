# Uomi

**Uomi** is a transaction management system for groups. 
Users can log bills and split the costs between others, 
and keep track of who owes whom. The application also 
helps users to settle up using common payment 
applications such as PayPal and Apple Pay.

## User Stories
--------------------

The following **priority** functionality is completed:

- [ ] 
  

The following **optional** features are implemented:

- [ ] Users can sign in with OAuth
- [ ] Users maintain a friends list
- [ ] Users can create event groups
- [ ] Users can add friends to groups
- [ ] Members of a group can log a transaction consisting of:
  - [ ] Name
  - [ ] Description
  - [ ] Location (coordinates)
  - [ ] Business (inferred from location if possible)
  - [ ] Picture
  - [ ] Payer
  - [ ] Total paid
  - [ ] Contributing members
  - [ ] Division of payment
- [ ] Users can see how is owed them or they owe within an event
- [ ] Users can see how much is owed them or that they owe friends in general
- [ ] Users can ask the application to recommend a payer for a transaction
  - [ ] The recommender calculates who in the group owes the most to all other parties within the event context
  - [ ] The recommender calculates who in the group owes the most to all other parties globally
  - [ ] The recommender randomly selects a user from the pool of most-qualified candidates if there is no clear choice
  - [ ] The recommender displays a popup for the user to confirm the selection
    - [ ] the reason for selecting the candidate is displayed
    - [ ] Users can accept, reject, or re-calculate (if it's between several payers) the selection
  - [ ] The recommender prompts the users to select from the best candidates. The popup includes an option to have the recommender randomly select one of the candidates
- [ ] Users can submit a payment via other apps
- [ ] When a user pays through another app, a confirmation resolves the dollar amount between the parties
- [ ] Users can log a manual (cash) payment in addition to paying through other apps
- [ ] Users see the most recently edited events in their event list page
- [ ] Users see the most recent transactions in their event transaction view
- [ ] When a user assigns another user to a transaction share, the other user must confirm
- [ ] Users can end an event to prevent additional transactions from being added

The following **additional** features are implemented:

- [ ] 



## Video Walkthrough 

Here's a walkthrough of implemented user stories:

__

## Notes


## License

Copyright 2017 Team Uomi: Eric Gonzalez, Yerania Hernandez, Kevin J Nguyen


