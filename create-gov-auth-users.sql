-- Create Supabase Auth users for government officials
-- Run this in Supabase SQL Editor with service role permissions

-- This script creates the actual auth users that correspond to the government_officials records

-- Note: This requires the service role key and should be run carefully
-- The passwords will be set to the values specified in the documentation

DO $$
DECLARE
    official_record RECORD;
    auth_user_id UUID;
BEGIN
    -- Create auth users for each government official
    FOR official_record IN
        SELECT id, employee_id, name, email FROM government_officials
        WHERE is_active = true
    LOOP
        -- Check if auth user already exists
        SELECT au.id INTO auth_user_id
        FROM auth.users au
        WHERE au.email = official_record.email;

        IF auth_user_id IS NULL THEN
            -- Create new auth user
            INSERT INTO auth.users (
                instance_id,
                id,
                aud,
                role,
                email,
                encrypted_password,
                email_confirmed_at,
                invited_at,
                confirmation_token,
                recovery_token,
                email_change_token_new,
                user_metadata,
                created_at,
                updated_at,
                phone,
                phone_confirmed_at,
                confirmed_at,
                last_sign_in_at,
                app_metadata,
                is_super_admin,
                raw_app_meta_data,
                raw_user_meta_data,
                is_sso_user,
                deleted_at,
                is_anonymous
            ) VALUES (
                '00000000-0000-0000-0000-000000000000', -- default instance_id
                official_record.id, -- Use the same ID as government_officials
                'authenticated',
                'authenticated',
                official_record.email,
                crypt('gov123456', gen_salt('bf')), -- Hash the password 'gov123456'
                NOW(), -- email_confirmed_at
                NULL, -- invited_at
                '', -- confirmation_token
                '', -- recovery_token
                '', -- email_change_token_new
                jsonb_build_object(
                    'full_name', official_record.name,
                    'role', 'government'
                ), -- user_metadata
                NOW(), -- created_at
                NOW(), -- updated_at
                NULL, -- phone
                NULL, -- phone_confirmed_at
                NOW(), -- confirmed_at
                NULL, -- last_sign_in_at
                jsonb_build_object('provider', 'email', 'providers', ARRAY['email']), -- app_metadata
                false, -- is_super_admin
                jsonb_build_object('provider', 'email', 'providers', ARRAY['email']), -- raw_app_meta_data
                jsonb_build_object(
                    'full_name', official_record.name,
                    'role', 'government'
                ), -- raw_user_meta_data
                false, -- is_sso_user
                NULL, -- deleted_at
                false -- is_anonymous
            );

            RAISE NOTICE 'Created auth user for government official: % (%)', official_record.name, official_record.email;
        ELSE
            RAISE NOTICE 'Auth user already exists for: % (%)', official_record.name, official_record.email;
        END IF;
    END LOOP;

    RAISE NOTICE 'Government official auth users creation completed';
END $$;