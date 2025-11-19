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
    afterEvaluate {
        val androidExt = project.extensions.findByName("android")
        if (androidExt != null) {
            val getNs = androidExt.javaClass.methods.find { it.name == "getNamespace" && it.parameterCount == 0 }
            val currentNs = getNs?.invoke(androidExt) as? String
            if (currentNs == null || currentNs.isBlank()) {
                val setNs = androidExt.javaClass.methods.find { it.name == "setNamespace" && it.parameterCount == 1 }
                setNs?.invoke(androidExt, project.group.toString())
            }
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
