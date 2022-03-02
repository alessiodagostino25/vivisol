public class SingletonClass {
    private static Boolean isAlreadyFired = false;

    public static Boolean checkNotToFire() {
        return isAlreadyFired;
    }

    public static void setFlag() {
        SingletonClass.isAlreadyFired = true;
    }
}