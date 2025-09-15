allprojects {
    repositories {
        google()
        mavenCentral()
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

// Workaround: Some third-party Gradle library modules (from Flutter plugins)
// may miss an explicit `namespace` required by AGP 8+. Set a sensible default
// namespace for any Android library subproject that doesn't declare one.
subprojects {
    plugins.withId("com.android.library") {
        // Ensure a namespace for AGP 8+; applies to library modules (plugins)
        extensions.configure<Any>("android") {
            try {
                val method = this.javaClass.methods.firstOrNull {
                    it.name == "setNamespace" && it.parameterTypes.size == 1 && it.parameterTypes[0] == String::class.java
                }
                if (method != null) {
                    val ns = "com.khpos.cashier.${project.name.replace('-', '_')}"
                    method.invoke(this, ns)
                }
            } catch (_: Throwable) {
                // ignore
            }
        }
    }
}
