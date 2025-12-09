-- CreateTable
CREATE TABLE `file_audits` (
    `id` VARCHAR(191) NOT NULL,
    `userId` VARCHAR(255) NOT NULL,
    `fileKey` VARCHAR(255) NOT NULL,
    `action` VARCHAR(50) NOT NULL,
    `fileName` VARCHAR(500) NULL,
    `contentType` VARCHAR(100) NULL,
    `durationSeconds` INTEGER NULL,
    `metadata` JSON NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `file_audits_userId_idx`(`userId`),
    INDEX `file_audits_fileKey_idx`(`fileKey`),
    INDEX `file_audits_createdAt_idx`(`createdAt`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
