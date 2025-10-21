package proguard.annotation

@Target(
    AnnotationTarget.CLASS,
    AnnotationTarget.FUNCTION,
    AnnotationTarget.PROPERTY,
    AnnotationTarget.CONSTRUCTOR,
    AnnotationTarget.FIELD
)
@Retention(AnnotationRetention.BINARY)
annotation class Keep

@Target(AnnotationTarget.CLASS)
@Retention(AnnotationRetention.BINARY)
annotation class KeepClassMembers

@Target(AnnotationTarget.CLASS)
@Retention(AnnotationRetention.BINARY)
annotation class KeepClassMemberNames

@Target(
    AnnotationTarget.CLASS,
    AnnotationTarget.FUNCTION,
    AnnotationTarget.PROPERTY,
    AnnotationTarget.CONSTRUCTOR,
    AnnotationTarget.FIELD
)
@Retention(AnnotationRetention.BINARY)
annotation class KeepName
