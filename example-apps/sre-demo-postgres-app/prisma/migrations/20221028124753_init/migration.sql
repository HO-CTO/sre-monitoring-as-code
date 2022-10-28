-- CreateTable
CREATE TABLE "CustomMetricsLogs" (
    "id" SERIAL NOT NULL,
    "version" TEXT NOT NULL,
    "metric" TEXT NOT NULL,
    "api" TEXT NOT NULL,

    CONSTRAINT "CustomMetricsLogs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Counter" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "value" INTEGER NOT NULL,
    "labels" TEXT[],

    CONSTRAINT "Counter_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Gauge" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "value" INTEGER NOT NULL,
    "labels" TEXT[],

    CONSTRAINT "Gauge_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Histogram" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "buckets" INTEGER[],
    "observe" INTEGER[],
    "labels" TEXT[],

    CONSTRAINT "Histogram_pkey" PRIMARY KEY ("id")
);
