import org.gradle.api.artifacts.repositories.MavenArtifactRepository

allprojects {
    repositories {
        google()
        mavenCentral()
        // androidx.test:* (integration_test uses runner:1.2+) must not be
        // resolved from FLUTTER_STORAGE_BASE_URL/download.flutter.io.
        // That host is a Flutter-engine Maven mirror; querying
        // androidx/test/runner/maven-metadata.xml there returns HTTP 403.
        exclusiveContent {
            forRepository { google() }
            filter {
                includeGroupByRegex("androidx\\.test.*")
            }
        }
    }
    repositories.whenObjectAdded {
        if (this is MavenArtifactRepository &&
            url.toString().contains("download.flutter.io")) {
            content {
                includeGroup("io.flutter")
            }
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
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
