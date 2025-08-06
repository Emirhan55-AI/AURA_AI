# Aura Database Migration Instructions

## Database Schema Setup

Follow these steps to set up the database schema in your Supabase project:

### Step 1: Access Supabase Dashboard
1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Login with your account
3. Select your project: `xfhndwilktambhujrejx`

### Step 2: Open SQL Editor
1. In the left sidebar, click on "SQL Editor"
2. Click on "New Query" to create a new SQL script

### Step 3: Run Migration Script
1. Copy the entire content from `supabase/migrations/20250805_initial_schema.sql`
2. Paste it into the SQL Editor
3. Click "Run" to execute the migration

### Step 4: Verify Installation
1. Go to "Database" → "Tables" in the left sidebar
2. You should see the following tables:
   - `users`
   - `profiles` 
   - `clothing_items`
   - `combinations`
   - `combination_items`
   - `follows`
   - `likes`
   - `comments`
   - `swap_listings`
   - `notifications`

### Step 5: Test Database Connection
Run the database test application to verify everything is working:
```bash
cd C:\Users\fower\Desktop\Aura\apps\flutter_app
flutter run -d chrome -t test_database_schema.dart
```

## Expected Results After Migration

✅ **Tables Created**: All 10 core tables with proper relationships
✅ **RLS Enabled**: Row Level Security policies active on all tables  
✅ **Triggers**: Auto-update timestamps on all relevant tables
✅ **Indexes**: Performance indexes on key columns
✅ **Functions**: Automatic counter updates (likes_count, etc.)

## Troubleshooting

### If Migration Fails:
1. Check for syntax errors in the SQL
2. Ensure you have proper permissions
3. Try running sections of the migration individually

### If Tables Don't Appear:
1. Refresh the browser
2. Check the "Logs" tab in Supabase for errors
3. Verify the SQL executed completely

### If RLS Policies Don't Work:
1. Ensure you're authenticated when testing
2. Check policy conditions match your use case
3. Review the auth context (auth.uid())

## Next Steps After Migration

1. **Test Basic Operations**: Use the test app to verify CRUD operations
2. **Setup Authentication**: Configure authentication providers if needed
3. **Test RLS Policies**: Verify data isolation between users
4. **Add Sample Data**: Insert test data for development
5. **Connect Flutter App**: Update repository classes to use real database

## Migration File Location
- Main migration: `supabase/migrations/20250805_initial_schema.sql`
- Config file: `supabase/config.toml`
- Test application: `test_database_schema.dart`

## Support
If you encounter issues, check:
- [Supabase Documentation](https://supabase.com/docs)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- Project's `docs/architecture/DATABASE_SCHEMA.md` for detailed schema info
