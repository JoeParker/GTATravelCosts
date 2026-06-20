module CostConfig

public class WarpConfig {
    @runtimeProperty("ModSettings.mod", "GTA TRAVEL COSTS")
    @runtimeProperty("ModSettings.category", "Meter")
    @runtimeProperty("ModSettings.displayName", "Cost Meter")
    @runtimeProperty("ModSettings.description", "Distance * this value defaults to 1.0")
    @runtimeProperty("ModSettings.step", "0.05")
    @runtimeProperty("ModSettings.min", "0.05")
    @runtimeProperty("ModSettings.max", "2")
    let CostMeter: Float = 0.1;

    @runtimeProperty("ModSettings.mod", "GTA TRAVEL COSTS")
    @runtimeProperty("ModSettings.category", "Duration")
    @runtimeProperty("ModSettings.displayName", "Duration of Message")
    @runtimeProperty("ModSettings.description", "The message is displayed for 10 seconds.")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "0")
    @runtimeProperty("ModSettings.max", "100")
    let TimeDuration: Float = 5.0;
}