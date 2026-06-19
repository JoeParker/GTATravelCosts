module CostConfig

public class WarpConfig {
	@runtimeProperty("ModSettings.mod", "FAST TRAVEL COST")
	@runtimeProperty("ModSettings.category", "Disable autosave")
	@runtimeProperty("ModSettings.displayName", "Disable Fast Travel AutoSave")
    @runtimeProperty("ModSettings.description", "Toggle to disable autosave after fast travel.")
    let DisableAfterFastTravel: Bool = true;

    @runtimeProperty("ModSettings.mod", "FAST TRAVEL COST")
    @runtimeProperty("ModSettings.category", "Meter")
    @runtimeProperty("ModSettings.displayName", "Cost Meter")
    @runtimeProperty("ModSettings.description", "Distance * this value defaults to 1.0")
    @runtimeProperty("ModSettings.step", "0.05")
    @runtimeProperty("ModSettings.min", "0.05")
    @runtimeProperty("ModSettings.max", "2")
    let CostMeter: Float = 0.1;

    @runtimeProperty("ModSettings.mod", "FAST TRAVEL COST")
    @runtimeProperty("ModSettings.category", "Duration")
    @runtimeProperty("ModSettings.displayName", "Duration of Message")
    @runtimeProperty("ModSettings.description", "The message is displayed for 10 seconds.")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "0")
    @runtimeProperty("ModSettings.max", "100")
    let TimeDuration: Float = 5.0;
}