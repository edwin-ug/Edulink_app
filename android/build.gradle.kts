buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // 1. Android Tools (Required)
        classpath("com.android.tools.build:gradle:8.3.0") 
        
        // 2. Kotlin (Required)
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.0") 
        
        // 3. FIREBASE GOOGLE SERVICES (The missing link!)
        classpath("com.google.gms:google-services:4.4.1")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}