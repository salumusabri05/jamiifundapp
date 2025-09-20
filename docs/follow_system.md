# Instagram-style Follow System Implementation

This document explains how the Instagram-style follow system works in the JamiiFund application.

## Database Schema

The system relies on the `user_follows` table with the following structure:

```sql
CREATE TABLE user_follows (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  follower_id UUID NOT NULL REFERENCES profiles(id),
  followed_id UUID NOT NULL REFERENCES profiles(id),
  status VARCHAR(255) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Ensure no duplicate follows
  UNIQUE(follower_id, followed_id)
);
```

## Follow States

The system has the following states:

1. **Not Following**: No record in the `user_follows` table
2. **Requested**: Record exists with `status = 'pending'`
3. **Following**: Record exists with `status = 'accepted'`
4. **Mutual Followers**: Both users have `status = 'accepted'` follow relationships with each other

## User Flows

### Follow User
1. User A clicks "Follow" on User B's profile
2. A record is created in `user_follows` with:
   - `follower_id = User A's ID`
   - `followed_id = User B's ID`
   - `status = 'pending'`
3. User B receives a follow request notification
4. User B can either accept or reject the request

### Accept Follow Request
1. User B clicks "Accept" on User A's follow request
2. The record in `user_follows` is updated with:
   - `status = 'accepted'`
3. User A is now following User B

### Reject Follow Request
1. User B clicks "Reject" on User A's follow request
2. The record in `user_follows` is deleted
3. User A is not following User B

### Unfollow User
1. User A clicks "Unfollow" on User B's profile
2. The record in `user_follows` is deleted
3. User A is no longer following User B

## Mutual Follow Status

Two users are considered mutual followers if:
1. User A has an accepted follow relationship with User B
2. User B has an accepted follow relationship with User A

Mutual followers can message each other in the chat feature.

## UI Components

### Follow Button States
- **Not Following**: "Follow" button in purple
- **Requested**: "Requested" button in orange
- **Following**: "Following" button in green

### Follow Request Tab
- Shows all pending follow requests
- Displays "Accept" and "Reject" buttons for each request

### User Profile
- Shows mutual follow status if applicable
- Shows pending request status if applicable
- Enables messaging only for mutual followers

## API Methods

The system uses the following methods in the `UserService` class:

- `followUser(followerId, followedId)`: Send a follow request
- `unfollowUser(followerId, followedId)`: Unfollow or cancel request
- `acceptFollowRequest(followerId, followedId)`: Accept a follow request
- `rejectFollowRequest(followerId, followedId)`: Reject a follow request
- `getFollowedUsers(userId)`: Get users that userId follows (accepted only)
- `getFollowers(userId)`: Get users who follow userId (accepted only)
- `getPendingFollowRequests(userId)`: Get users who have sent follow requests to userId
- `getFollowRequestStatus(followerId, followedId)`: Get status of a follow relationship

## Deployment Instructions

1. Create the `user_follows` table in your Supabase database using the SQL script in `supabase/migrations/user_follows.sql`
2. Update any existing follow relationships to have `status = 'accepted'`
3. Deploy the updated application code
