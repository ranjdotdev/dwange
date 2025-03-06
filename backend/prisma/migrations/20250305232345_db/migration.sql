-- CreateEnum
CREATE TYPE "UserStatus" AS ENUM ('ACTIVE', 'SUSPENDED', 'DEACTIVATED', 'PENDING_DELETION', 'BANNED');

-- CreateEnum
CREATE TYPE "UserRole" AS ENUM ('USER', 'MODERATOR', 'ADMIN');

-- CreateEnum
CREATE TYPE "PostType" AS ENUM ('POST', 'COMMENT', 'SHARE');

-- CreateEnum
CREATE TYPE "PostAudience" AS ENUM ('ONLY_ME', 'FRIENDS', 'MY_COMMUNITIES', 'PUBLIC');

-- CreateEnum
CREATE TYPE "MediaType" AS ENUM ('IMAGE', 'VIDEO', 'GIF', 'AUDIO', 'DOCUMENT');

-- CreateEnum
CREATE TYPE "CommunityRole" AS ENUM ('MEMBER', 'MODERATOR', 'ADMIN', 'OWNER');

-- CreateEnum
CREATE TYPE "JoinRequestStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED');

-- CreateEnum
CREATE TYPE "ScheduledPostStatus" AS ENUM ('PENDING', 'PUBLISHED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "NotificationType" AS ENUM ('LIKE', 'COMMENT', 'REPLY', 'SHARE', 'FOLLOW', 'MENTION', 'COMMUNITY_INVITE', 'POLL_VOTE', 'JOIN_REQUEST', 'JOIN_APPROVED');

-- CreateTable
CREATE TABLE "users" (
    "id" TEXT NOT NULL,
    "username" VARCHAR(30) NOT NULL,
    "email" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "bio" TEXT,
    "location" VARCHAR(100),
    "website" VARCHAR(255),
    "image_url" VARCHAR(255),
    "gender" VARCHAR(6),
    "role" "UserRole" NOT NULL DEFAULT 'USER',
    "following_count" INTEGER NOT NULL DEFAULT 0,
    "followers_count" INTEGER NOT NULL DEFAULT 0,
    "posts_count" INTEGER NOT NULL DEFAULT 0,
    "email_verified" BOOLEAN NOT NULL DEFAULT false,
    "status" "UserStatus" NOT NULL DEFAULT 'ACTIVE',
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMPTZ(6),
    "birth_date" DATE,
    "last_login_at" TIMESTAMPTZ(6),

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "followers" (
    "id" TEXT NOT NULL,
    "follower_id" TEXT NOT NULL,
    "followed_id" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "followers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "sessions" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "token" TEXT NOT NULL,
    "ip_address" VARCHAR(45),
    "user_agent" TEXT,
    "is_valid" BOOLEAN NOT NULL DEFAULT true,
    "expires_at" TIMESTAMPTZ(6) NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "last_used_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "sessions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "posts" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "content" TEXT,
    "parent_id" TEXT,
    "root_id" TEXT,
    "community_id" TEXT,
    "audience" "PostAudience" NOT NULL DEFAULT 'PUBLIC',
    "location" VARCHAR(255),
    "likes_count" INTEGER NOT NULL DEFAULT 0,
    "comments_count" INTEGER NOT NULL DEFAULT 0,
    "shares_count" INTEGER NOT NULL DEFAULT 0,
    "has_poll" BOOLEAN NOT NULL DEFAULT false,
    "is_edited" BOOLEAN NOT NULL DEFAULT false,
    "is_pinned" BOOLEAN NOT NULL DEFAULT false,
    "scheduled_for" TIMESTAMPTZ(6),
    "published_at" TIMESTAMPTZ(6),
    "deleted_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "shared_post_id" TEXT,
    "type" "PostType" NOT NULL DEFAULT 'POST',

    CONSTRAINT "posts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "post_media" (
    "id" TEXT NOT NULL,
    "post_id" TEXT NOT NULL,
    "mediaType" "MediaType" NOT NULL,
    "media_url" VARCHAR(255) NOT NULL,
    "alt_text" TEXT,
    "width" INTEGER,
    "height" INTEGER,
    "duration" INTEGER,
    "thumbnail_url" VARCHAR(255),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "post_media_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "polls" (
    "id" TEXT NOT NULL,
    "post_id" TEXT NOT NULL,
    "question" TEXT NOT NULL,
    "closes_at" TIMESTAMPTZ(6),
    "allow_multiple_choices" BOOLEAN NOT NULL DEFAULT false,
    "is_anonymous" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "polls_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "poll_options" (
    "id" TEXT NOT NULL,
    "poll_id" TEXT NOT NULL,
    "option_text" TEXT NOT NULL,
    "vote_count" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "poll_options_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "poll_votes" (
    "id" TEXT NOT NULL,
    "poll_id" TEXT NOT NULL,
    "option_id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "poll_votes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "likes" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "post_id" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "likes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "bookmarks" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "post_id" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "bookmarks_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "communities" (
    "id" TEXT NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "slug" VARCHAR(100) NOT NULL,
    "description" TEXT,
    "image_url" VARCHAR(255),
    "banner_url" VARCHAR(255),
    "is_private" BOOLEAN NOT NULL DEFAULT false,
    "is_verified" BOOLEAN NOT NULL DEFAULT false,
    "members_count" INTEGER NOT NULL DEFAULT 0,
    "posts_count" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "creator_id" TEXT NOT NULL,

    CONSTRAINT "communities_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "community_members" (
    "id" TEXT NOT NULL,
    "community_id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "role" "CommunityRole" NOT NULL DEFAULT 'MEMBER',
    "is_approved" BOOLEAN NOT NULL DEFAULT true,
    "joined_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "community_members_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "community_join_requests" (
    "id" TEXT NOT NULL,
    "community_id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "message" TEXT,
    "status" "JoinRequestStatus" NOT NULL DEFAULT 'PENDING',
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "community_join_requests_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "scheduled_posts" (
    "id" TEXT NOT NULL,
    "post_id" TEXT NOT NULL,
    "scheduled_time" TIMESTAMPTZ(6) NOT NULL,
    "status" "ScheduledPostStatus" NOT NULL DEFAULT 'PENDING',
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "scheduled_posts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "notifications" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "type" "NotificationType" NOT NULL,
    "actor_id" TEXT,
    "post_id" TEXT,
    "community_id" TEXT,
    "is_read" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "notifications_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "hashtags" (
    "id" TEXT NOT NULL,
    "name" VARCHAR(50) NOT NULL,
    "post_count" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "hashtags_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "post_hashtags" (
    "id" TEXT NOT NULL,
    "post_id" TEXT NOT NULL,
    "hashtag_id" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "post_hashtags_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "trending_topics" (
    "id" TEXT NOT NULL,
    "hashtag_id" TEXT NOT NULL,
    "rank" INTEGER NOT NULL,
    "volume" INTEGER NOT NULL,
    "region" VARCHAR(100),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "trending_topics_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_verifications" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "identity_verified" BOOLEAN NOT NULL DEFAULT false,
    "public_figure" BOOLEAN NOT NULL DEFAULT false,
    "verified_at" TIMESTAMPTZ(6),
    "verification_doc_id" VARCHAR(255),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_verifications_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_reports" (
    "id" TEXT NOT NULL,
    "reporter_id" TEXT NOT NULL,
    "reported_user_id" TEXT NOT NULL,
    "post_id" TEXT,
    "reason" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'PENDING',
    "reviewed_at" TIMESTAMPTZ(6),
    "reviewer_notes" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_reports_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_activities" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "activityType" TEXT NOT NULL,
    "ip_address" VARCHAR(45),
    "user_agent" TEXT,
    "location" VARCHAR(100),
    "device_type" VARCHAR(50),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_activities_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "post_analytics" (
    "id" TEXT NOT NULL,
    "post_id" TEXT NOT NULL,
    "impressions" INTEGER NOT NULL DEFAULT 0,
    "engagement_rate" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "click_count" INTEGER NOT NULL DEFAULT 0,
    "share_count" INTEGER NOT NULL DEFAULT 0,
    "save_count" INTEGER NOT NULL DEFAULT 0,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "post_analytics_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "conversations" (
    "id" TEXT NOT NULL,
    "is_group" BOOLEAN NOT NULL DEFAULT false,
    "name" VARCHAR(100),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "conversations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "conversation_participants" (
    "id" TEXT NOT NULL,
    "conversation_id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "is_admin" BOOLEAN NOT NULL DEFAULT false,
    "last_read_at" TIMESTAMPTZ(6),
    "joined_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "conversation_participants_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "messages" (
    "id" TEXT NOT NULL,
    "conversation_id" TEXT NOT NULL,
    "sender_id" TEXT NOT NULL,
    "content" TEXT,
    "media_url" VARCHAR(255),
    "mediaType" "MediaType",
    "is_edited" BOOLEAN NOT NULL DEFAULT false,
    "deleted_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "messages_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "message_read_status" (
    "id" TEXT NOT NULL,
    "message_id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "read_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "message_read_status_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_username_key" ON "users"("username");

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE INDEX "users_username_idx" ON "users"("username");

-- CreateIndex
CREATE INDEX "users_email_idx" ON "users"("email");

-- CreateIndex
CREATE INDEX "users_status_idx" ON "users"("status");

-- CreateIndex
CREATE INDEX "users_created_at_idx" ON "users"("created_at");

-- CreateIndex
CREATE INDEX "followers_follower_id_idx" ON "followers"("follower_id");

-- CreateIndex
CREATE INDEX "followers_followed_id_idx" ON "followers"("followed_id");

-- CreateIndex
CREATE UNIQUE INDEX "followers_follower_id_followed_id_key" ON "followers"("follower_id", "followed_id");

-- CreateIndex
CREATE UNIQUE INDEX "sessions_token_key" ON "sessions"("token");

-- CreateIndex
CREATE INDEX "sessions_user_id_idx" ON "sessions"("user_id");

-- CreateIndex
CREATE INDEX "sessions_token_idx" ON "sessions"("token");

-- CreateIndex
CREATE INDEX "sessions_expires_at_idx" ON "sessions"("expires_at");

-- CreateIndex
CREATE INDEX "sessions_created_at_idx" ON "sessions"("created_at");

-- CreateIndex
CREATE INDEX "posts_user_id_idx" ON "posts"("user_id");

-- CreateIndex
CREATE INDEX "posts_parent_id_idx" ON "posts"("parent_id");

-- CreateIndex
CREATE INDEX "posts_root_id_idx" ON "posts"("root_id");

-- CreateIndex
CREATE INDEX "posts_community_id_idx" ON "posts"("community_id");

-- CreateIndex
CREATE INDEX "posts_created_at_idx" ON "posts"("created_at");

-- CreateIndex
CREATE INDEX "posts_shared_post_id_idx" ON "posts"("shared_post_id");

-- CreateIndex
CREATE INDEX "posts_type_idx" ON "posts"("type");

-- CreateIndex
CREATE INDEX "post_media_post_id_idx" ON "post_media"("post_id");

-- CreateIndex
CREATE INDEX "post_media_mediaType_idx" ON "post_media"("mediaType");

-- CreateIndex
CREATE UNIQUE INDEX "polls_post_id_key" ON "polls"("post_id");

-- CreateIndex
CREATE INDEX "polls_post_id_idx" ON "polls"("post_id");

-- CreateIndex
CREATE INDEX "polls_closes_at_idx" ON "polls"("closes_at");

-- CreateIndex
CREATE INDEX "poll_options_poll_id_idx" ON "poll_options"("poll_id");

-- CreateIndex
CREATE INDEX "poll_votes_poll_id_idx" ON "poll_votes"("poll_id");

-- CreateIndex
CREATE INDEX "poll_votes_user_id_idx" ON "poll_votes"("user_id");

-- CreateIndex
CREATE INDEX "poll_votes_option_id_idx" ON "poll_votes"("option_id");

-- CreateIndex
CREATE UNIQUE INDEX "poll_votes_user_id_poll_id_key" ON "poll_votes"("user_id", "poll_id");

-- CreateIndex
CREATE INDEX "likes_user_id_idx" ON "likes"("user_id");

-- CreateIndex
CREATE INDEX "likes_post_id_idx" ON "likes"("post_id");

-- CreateIndex
CREATE INDEX "likes_created_at_idx" ON "likes"("created_at");

-- CreateIndex
CREATE UNIQUE INDEX "likes_user_id_post_id_key" ON "likes"("user_id", "post_id");

-- CreateIndex
CREATE INDEX "bookmarks_user_id_idx" ON "bookmarks"("user_id");

-- CreateIndex
CREATE INDEX "bookmarks_post_id_idx" ON "bookmarks"("post_id");

-- CreateIndex
CREATE INDEX "bookmarks_created_at_idx" ON "bookmarks"("created_at");

-- CreateIndex
CREATE UNIQUE INDEX "bookmarks_user_id_post_id_key" ON "bookmarks"("user_id", "post_id");

-- CreateIndex
CREATE UNIQUE INDEX "communities_slug_key" ON "communities"("slug");

-- CreateIndex
CREATE INDEX "communities_name_idx" ON "communities"("name");

-- CreateIndex
CREATE INDEX "communities_slug_idx" ON "communities"("slug");

-- CreateIndex
CREATE INDEX "communities_is_private_idx" ON "communities"("is_private");

-- CreateIndex
CREATE INDEX "communities_creator_id_idx" ON "communities"("creator_id");

-- CreateIndex
CREATE INDEX "communities_created_at_idx" ON "communities"("created_at");

-- CreateIndex
CREATE INDEX "community_members_community_id_idx" ON "community_members"("community_id");

-- CreateIndex
CREATE INDEX "community_members_user_id_idx" ON "community_members"("user_id");

-- CreateIndex
CREATE INDEX "community_members_role_idx" ON "community_members"("role");

-- CreateIndex
CREATE UNIQUE INDEX "community_members_community_id_user_id_key" ON "community_members"("community_id", "user_id");

-- CreateIndex
CREATE INDEX "community_join_requests_community_id_idx" ON "community_join_requests"("community_id");

-- CreateIndex
CREATE INDEX "community_join_requests_user_id_idx" ON "community_join_requests"("user_id");

-- CreateIndex
CREATE INDEX "community_join_requests_status_idx" ON "community_join_requests"("status");

-- CreateIndex
CREATE UNIQUE INDEX "community_join_requests_community_id_user_id_key" ON "community_join_requests"("community_id", "user_id");

-- CreateIndex
CREATE UNIQUE INDEX "scheduled_posts_post_id_key" ON "scheduled_posts"("post_id");

-- CreateIndex
CREATE INDEX "scheduled_posts_post_id_idx" ON "scheduled_posts"("post_id");

-- CreateIndex
CREATE INDEX "scheduled_posts_scheduled_time_idx" ON "scheduled_posts"("scheduled_time");

-- CreateIndex
CREATE INDEX "scheduled_posts_status_idx" ON "scheduled_posts"("status");

-- CreateIndex
CREATE INDEX "notifications_user_id_idx" ON "notifications"("user_id");

-- CreateIndex
CREATE INDEX "notifications_created_at_idx" ON "notifications"("created_at");

-- CreateIndex
CREATE INDEX "notifications_is_read_idx" ON "notifications"("is_read");

-- CreateIndex
CREATE INDEX "notifications_type_idx" ON "notifications"("type");

-- CreateIndex
CREATE UNIQUE INDEX "hashtags_name_key" ON "hashtags"("name");

-- CreateIndex
CREATE INDEX "hashtags_name_idx" ON "hashtags"("name");

-- CreateIndex
CREATE INDEX "hashtags_post_count_idx" ON "hashtags"("post_count");

-- CreateIndex
CREATE INDEX "post_hashtags_post_id_idx" ON "post_hashtags"("post_id");

-- CreateIndex
CREATE INDEX "post_hashtags_hashtag_id_idx" ON "post_hashtags"("hashtag_id");

-- CreateIndex
CREATE UNIQUE INDEX "post_hashtags_post_id_hashtag_id_key" ON "post_hashtags"("post_id", "hashtag_id");

-- CreateIndex
CREATE INDEX "trending_topics_rank_idx" ON "trending_topics"("rank");

-- CreateIndex
CREATE INDEX "trending_topics_region_idx" ON "trending_topics"("region");

-- CreateIndex
CREATE UNIQUE INDEX "trending_topics_hashtag_id_region_key" ON "trending_topics"("hashtag_id", "region");

-- CreateIndex
CREATE UNIQUE INDEX "user_verifications_user_id_key" ON "user_verifications"("user_id");

-- CreateIndex
CREATE INDEX "user_verifications_user_id_idx" ON "user_verifications"("user_id");

-- CreateIndex
CREATE INDEX "user_reports_reporter_id_idx" ON "user_reports"("reporter_id");

-- CreateIndex
CREATE INDEX "user_reports_reported_user_id_idx" ON "user_reports"("reported_user_id");

-- CreateIndex
CREATE INDEX "user_reports_post_id_idx" ON "user_reports"("post_id");

-- CreateIndex
CREATE INDEX "user_reports_status_idx" ON "user_reports"("status");

-- CreateIndex
CREATE INDEX "user_activities_user_id_idx" ON "user_activities"("user_id");

-- CreateIndex
CREATE INDEX "user_activities_activityType_idx" ON "user_activities"("activityType");

-- CreateIndex
CREATE INDEX "user_activities_created_at_idx" ON "user_activities"("created_at");

-- CreateIndex
CREATE UNIQUE INDEX "post_analytics_post_id_key" ON "post_analytics"("post_id");

-- CreateIndex
CREATE INDEX "post_analytics_post_id_idx" ON "post_analytics"("post_id");

-- CreateIndex
CREATE INDEX "conversations_created_at_idx" ON "conversations"("created_at");

-- CreateIndex
CREATE INDEX "conversation_participants_conversation_id_idx" ON "conversation_participants"("conversation_id");

-- CreateIndex
CREATE INDEX "conversation_participants_user_id_idx" ON "conversation_participants"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "conversation_participants_conversation_id_user_id_key" ON "conversation_participants"("conversation_id", "user_id");

-- CreateIndex
CREATE INDEX "messages_conversation_id_idx" ON "messages"("conversation_id");

-- CreateIndex
CREATE INDEX "messages_sender_id_idx" ON "messages"("sender_id");

-- CreateIndex
CREATE INDEX "messages_created_at_idx" ON "messages"("created_at");

-- CreateIndex
CREATE INDEX "message_read_status_message_id_idx" ON "message_read_status"("message_id");

-- CreateIndex
CREATE INDEX "message_read_status_user_id_idx" ON "message_read_status"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "message_read_status_message_id_user_id_key" ON "message_read_status"("message_id", "user_id");

-- AddForeignKey
ALTER TABLE "followers" ADD CONSTRAINT "followers_follower_id_fkey" FOREIGN KEY ("follower_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "followers" ADD CONSTRAINT "followers_followed_id_fkey" FOREIGN KEY ("followed_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sessions" ADD CONSTRAINT "sessions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "posts" ADD CONSTRAINT "posts_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "posts" ADD CONSTRAINT "posts_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "posts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "posts" ADD CONSTRAINT "posts_root_id_fkey" FOREIGN KEY ("root_id") REFERENCES "posts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "posts" ADD CONSTRAINT "posts_community_id_fkey" FOREIGN KEY ("community_id") REFERENCES "communities"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "posts" ADD CONSTRAINT "posts_shared_post_id_fkey" FOREIGN KEY ("shared_post_id") REFERENCES "posts"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "post_media" ADD CONSTRAINT "post_media_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "posts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "polls" ADD CONSTRAINT "polls_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "posts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "poll_options" ADD CONSTRAINT "poll_options_poll_id_fkey" FOREIGN KEY ("poll_id") REFERENCES "polls"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "poll_votes" ADD CONSTRAINT "poll_votes_poll_id_fkey" FOREIGN KEY ("poll_id") REFERENCES "polls"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "poll_votes" ADD CONSTRAINT "poll_votes_option_id_fkey" FOREIGN KEY ("option_id") REFERENCES "poll_options"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "poll_votes" ADD CONSTRAINT "poll_votes_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "likes" ADD CONSTRAINT "likes_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "likes" ADD CONSTRAINT "likes_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "posts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bookmarks" ADD CONSTRAINT "bookmarks_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bookmarks" ADD CONSTRAINT "bookmarks_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "posts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "communities" ADD CONSTRAINT "communities_creator_id_fkey" FOREIGN KEY ("creator_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "community_members" ADD CONSTRAINT "community_members_community_id_fkey" FOREIGN KEY ("community_id") REFERENCES "communities"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "community_members" ADD CONSTRAINT "community_members_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "community_join_requests" ADD CONSTRAINT "community_join_requests_community_id_fkey" FOREIGN KEY ("community_id") REFERENCES "communities"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "community_join_requests" ADD CONSTRAINT "community_join_requests_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "scheduled_posts" ADD CONSTRAINT "scheduled_posts_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "posts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_actor_id_fkey" FOREIGN KEY ("actor_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "posts"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_community_id_fkey" FOREIGN KEY ("community_id") REFERENCES "communities"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "post_hashtags" ADD CONSTRAINT "post_hashtags_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "posts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "post_hashtags" ADD CONSTRAINT "post_hashtags_hashtag_id_fkey" FOREIGN KEY ("hashtag_id") REFERENCES "hashtags"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "trending_topics" ADD CONSTRAINT "trending_topics_hashtag_id_fkey" FOREIGN KEY ("hashtag_id") REFERENCES "hashtags"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_verifications" ADD CONSTRAINT "user_verifications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_reports" ADD CONSTRAINT "user_reports_reporter_id_fkey" FOREIGN KEY ("reporter_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_reports" ADD CONSTRAINT "user_reports_reported_user_id_fkey" FOREIGN KEY ("reported_user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_reports" ADD CONSTRAINT "user_reports_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "posts"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_activities" ADD CONSTRAINT "user_activities_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "post_analytics" ADD CONSTRAINT "post_analytics_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "posts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "conversation_participants" ADD CONSTRAINT "conversation_participants_conversation_id_fkey" FOREIGN KEY ("conversation_id") REFERENCES "conversations"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "conversation_participants" ADD CONSTRAINT "conversation_participants_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "messages" ADD CONSTRAINT "messages_conversation_id_fkey" FOREIGN KEY ("conversation_id") REFERENCES "conversations"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "messages" ADD CONSTRAINT "messages_sender_id_fkey" FOREIGN KEY ("sender_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "message_read_status" ADD CONSTRAINT "message_read_status_message_id_fkey" FOREIGN KEY ("message_id") REFERENCES "messages"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "message_read_status" ADD CONSTRAINT "message_read_status_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
