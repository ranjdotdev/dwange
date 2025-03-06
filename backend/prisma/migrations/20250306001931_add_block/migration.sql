-- AlterTable
ALTER TABLE "users" ADD COLUMN     "blockers_count" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "blocking_count" INTEGER NOT NULL DEFAULT 0;

-- CreateTable
CREATE TABLE "blockers" (
    "id" TEXT NOT NULL,
    "blocker_id" TEXT NOT NULL,
    "blocked_id" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "blockers_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "blockers_blocker_id_idx" ON "blockers"("blocker_id");

-- CreateIndex
CREATE INDEX "blockers_blocked_id_idx" ON "blockers"("blocked_id");

-- CreateIndex
CREATE UNIQUE INDEX "blockers_blocker_id_blocked_id_key" ON "blockers"("blocker_id", "blocked_id");

-- AddForeignKey
ALTER TABLE "blockers" ADD CONSTRAINT "blockers_blocker_id_fkey" FOREIGN KEY ("blocker_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "blockers" ADD CONSTRAINT "blockers_blocked_id_fkey" FOREIGN KEY ("blocked_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
