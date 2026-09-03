# MIZAN release runtime guards.
# Google Mobile Ads initializes WorkManager through AndroidX Startup before
# Flutter's first frame. Room resolves WorkDatabase_Impl reflectively, so R8
# must retain the generated implementation and the initialization path.
-keep class androidx.work.impl.WorkDatabase_Impl { *; }
-keep class androidx.work.impl.** { *; }
-dontwarn androidx.work.impl.**

-keep class * extends androidx.room.RoomDatabase { *; }
-keep class androidx.room.**_Impl { *; }
-keep class androidx.sqlite.db.framework.FrameworkSQLiteOpenHelperFactory { *; }

-keep class androidx.startup.** { *; }
-keep class * implements androidx.startup.Initializer { *; }
