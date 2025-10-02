import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// SQL Functions to create in Supabase SQL Editor for user follows system
/// 
/// ```sql
/// -- Function to create a follow request
/// CREATE OR REPLACE FUNCTION create_follow_request(follower UUID, followed UUID)
/// RETURNS JSONB AS $$
/// DECLARE
///   result JSONB;
/// BEGIN
///   INSERT INTO user_follows (follower_id, followed_id, status, created_at)
///   VALUES (follower, followed, 'pending', NOW())
///   RETURNING to_jsonb(user_follows.*) INTO result;
///   RETURN result;
/// EXCEPTION
///   WHEN unique_violation THEN
///     RAISE EXCEPTION 'Follow request already exists';
///   WHEN others THEN
///     RAISE EXCEPTION 'Error creating follow request: %', SQLERRM;
/// END;
/// $$ LANGUAGE plpgsql SECURITY DEFINER;
///
/// -- Function to accept a follow request
/// CREATE OR REPLACE FUNCTION accept_follow_request(follower UUID, followed UUID)
/// RETURNS JSONB AS $$
/// DECLARE
///   result JSONB;
/// BEGIN
///   UPDATE user_follows
///   SET status = 'accepted', updated_at = NOW()
///   WHERE follower_id = follower AND followed_id = followed AND status = 'pending'
///   RETURNING to_jsonb(user_follows.*) INTO result;
///   
///   IF result IS NULL THEN
///     RAISE EXCEPTION 'No pending follow request found';
///   END IF;
///   
///   RETURN result;
/// EXCEPTION
///   WHEN others THEN
///     RAISE EXCEPTION 'Error accepting follow request: %', SQLERRM;
/// END;
/// $$ LANGUAGE plpgsql SECURITY DEFINER;
///
/// -- Function to reject/remove a follow request
/// CREATE OR REPLACE FUNCTION reject_follow_request(follower UUID, followed UUID)
/// RETURNS BOOLEAN AS $$
/// BEGIN
///   DELETE FROM user_follows
///   WHERE follower_id = follower AND followed_id = followed AND status = 'pending';
///   
///   RETURN FOUND;
/// EXCEPTION
///   WHEN others THEN
///     RAISE EXCEPTION 'Error rejecting follow request: %', SQLERRM;
/// END;
/// $$ LANGUAGE plpgsql SECURITY DEFINER;
///
/// -- Function to remove any follow relationship
/// CREATE OR REPLACE FUNCTION remove_follow_relationship(follower UUID, followed UUID)
/// RETURNS BOOLEAN AS $$
/// BEGIN
///   DELETE FROM user_follows
///   WHERE follower_id = follower AND followed_id = followed;
///   
///   RETURN FOUND;
/// EXCEPTION
///   WHEN others THEN
///     RAISE EXCEPTION 'Error removing follow relationship: %', SQLERRM;
/// END;
/// $$ LANGUAGE plpgsql SECURITY DEFINER;
///
/// -- Function to create a notification
/// CREATE OR REPLACE FUNCTION create_notification(
///   p_user_id UUID,
///   p_title TEXT,
///   p_message TEXT,
///   p_type TEXT DEFAULT 'info'
/// ) RETURNS JSONB AS $$
/// DECLARE
///   result JSONB;
/// BEGIN
///   INSERT INTO notifications (user_id, title, message, type, is_read, created_at)
///   VALUES (p_user_id, p_title, p_message, p_type, false, NOW())
///   RETURNING to_jsonb(notifications.*) INTO result;
///   
///   RETURN result;
/// EXCEPTION
///   WHEN others THEN
///     RAISE EXCEPTION 'Error creating notification: %', SQLERRM;
/// END;
/// $$ LANGUAGE plpgsql SECURITY DEFINER;
///
/// -- Function to execute SQL (admin only)
/// CREATE OR REPLACE FUNCTION exec_sql(sql text) 
/// RETURNS text AS $$
/// BEGIN
///   IF NOT (SELECT is_admin FROM profiles WHERE id = auth.uid()) THEN
///     RETURN 'Permission denied: Admin privileges required';
///   END IF;
///   
///   EXECUTE sql;
///   RETURN 'SQL executed successfully';
/// EXCEPTION
///   WHEN others THEN
///     RETURN 'SQL error: ' || SQLERRM;
/// END;
/// $$ LANGUAGE plpgsql SECURITY DEFINER;
/// ```

/// Row Level Security (RLS) policies for tables
/// ```sql
/// -- RLS for user_follows table
/// ALTER TABLE user_follows ENABLE ROW LEVEL SECURITY;
/// 
/// -- Policy to view only follows where user is follower or followed
/// CREATE POLICY view_own_follows ON user_follows
///   FOR SELECT USING (
///     auth.uid() IN (follower_id, followed_id)
///   );
/// 
/// -- Policy to insert only follows where user is follower
/// CREATE POLICY insert_own_follows ON user_follows
///   FOR INSERT WITH CHECK (
///     auth.uid() = follower_id
///   );
/// 
/// -- Policy to delete only follows where user is follower
/// CREATE POLICY delete_own_follows ON user_follows
///   FOR DELETE USING (
///     auth.uid() = follower_id
///   );
///   
/// -- Policy to update only where user is followed (for accepting/rejecting)
/// CREATE POLICY update_own_follows ON user_follows
///   FOR UPDATE USING (
///     auth.uid() = followed_id AND status = 'pending'
///   );
///   
/// -- RLS for notifications table
/// ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
/// 
/// -- Policy to view only own notifications
/// CREATE POLICY view_own_notifications ON notifications
///   FOR SELECT USING (
///     auth.uid() = user_id
///   );
///   
/// -- Policy to insert notifications for any user (for system notifications)
/// CREATE POLICY insert_notifications ON notifications
///   FOR INSERT WITH CHECK (TRUE);
///   
/// -- Policy to update only own notifications
/// CREATE POLICY update_own_notifications ON notifications
///   FOR UPDATE USING (
///     auth.uid() = user_id
///   );
/// ```

class SupabaseHelper {
  // Display a dialog with Supabase troubleshooting instructions
  static void showSupabaseTroubleshootingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Database Connection Issues'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'There seems to be an issue with the database connection.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'Possible solutions:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text('• Check your internet connection'),
                Text('• Verify that the Supabase service is online'),
                Text('• Make sure your SQL functions are created correctly'),
                Text('• Check Row Level Security policies'),
                SizedBox(height: 10),
                Text(
                  'You can try these SQL functions to fix common issues:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  '1. Create helper functions: Execute the SQL functions from the comments at the top of this file',
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 5),
                Text(
                  '2. Ensure proper RLS policies: Set up RLS policies as described in the comments',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
