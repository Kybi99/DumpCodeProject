import org.gradle.api.tasks.Delete
import java.io.File

// Root-level repository setup
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Buildscript dependencies (Kotlin, Google Services, etc.)
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.0")
        classpath("com.google.gms:google-services:4.4.3")
    }
}

// Custom build directory: apply only if project is inside the root project (not from .pub-cache)
val sharedBuildRoot = file("${rootDir}/../build")

allprojects {
    // Only apply to projects that are in the same directory tree as this project
    if (project.projectDir.absolutePath.startsWith(rootDir.absolutePath)) {
        buildDir = File(sharedBuildRoot, project.name)
    }
}

// Optional: avoid this unless necessary – it can introduce cyclic evaluations
// subprojects {
//     project.evaluationDependsOn(":app")
// }

// Custom clean task to wipe shared build directory
tasks.register<Delete>("clean") {
    delete(sharedBuildRoot)
}
