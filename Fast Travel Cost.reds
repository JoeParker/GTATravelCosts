import CostConfig.WarpConfig
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
								//CONFIG MESSAGE IN GAME// 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

public static func PaidMessage() -> String = s"Travel expenses: $" //<-----------text + $ is the amount
public static func UnAvailableMessage() -> String = s"You don't have enough money. "

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@addField(PlayerPuppet)
private let m_TravelPayment: ref<TravelPayment>;

@addMethod(PlayerPuppet)
public func GetTravelPayment() -> ref<TravelPayment> {
	return this.m_TravelPayment;
} 
 

public class FasttcSG {
	
	public static func ShowFastTravelPaidMessage(cc: GameInstance, moneyPaid: Int32) {
		let Config: ref<WarpConfig>;
		Config = new WarpConfig();
		let MessageDuration: Float;
		MessageDuration = Config.TimeDuration;
		let onscreenMsg: SimpleScreenMessage;
		onscreenMsg.duration = MessageDuration;
		onscreenMsg.isShown = true;		
		onscreenMsg.message = PaidMessage() + ToString(moneyPaid);
		onscreenMsg.type = SimpleMessageType.Money;
	
		GameInstance.GetBlackboardSystem(cc).Get(GetAllBlackboardDefs().UI_Notifications).SetVariant(GetAllBlackboardDefs		().UI_Notifications.WarningMessage, ToVariant(onscreenMsg), true);
	}
	
	
}

public class TravelPayment {
	private let m_player: wref<PlayerPuppet>;
	private let m_fastTravelBB: wref<IBlackboard>;
	private let m_lastPaymentCal: Int32;
	private let m_loadingScreenCallbackID: ref<CallbackHandle>;
	private let config: ref<WarpConfig>;
	
	private let scheduleMSG: Bool;
	
	public func Init(player: ref<PlayerPuppet>) {
		this.m_player = player;
		this.m_fastTravelBB = GameInstance.GetBlackboardSystem(this.m_player.GetGame()).Get(GetAllBlackboardDefs().FastTRavelSystem);

		FTLog("TravelPayment.Init");
		
		this.m_loadingScreenCallbackID = this.m_fastTravelBB.RegisterListenerBool(GetAllBlackboardDefs().FastTRavelSystem.FastTravelLoadingScreenFinished, this, n"OnLoadingScreenFinished");
	}

	public func Uninit() {
		FTLog("TravelPayment.Uninit");
		
		this.m_fastTravelBB.UnregisterListenerBool(GetAllBlackboardDefs().FastTRavelSystem.FastTravelLoadingScreenFinished, this.m_loadingScreenCallbackID);
	}
	
	public func PaymentCal(distance: Float) -> Int32 {
		this.config = new WarpConfig();
		let qualityCost: Float;
		qualityCost = this.config.CostMeter;

		this.m_lastPaymentCal = RoundMath(distance * qualityCost);
		return this.m_lastPaymentCal;
	}
	
	public func EnoughMoney(distance: Float) -> Bool {
		let buyPrice: Int32;
		let playerMoney: Int32;
		let tSystem: ref<TransactionSystem>;
		
		tSystem = GameInstance.GetTransactionSystem(this.m_player.GetGame());
		playerMoney = tSystem.GetItemQuantity(this.m_player, MarketSystem.Money());
		buyPrice = this.PaymentCal(distance);
		
		return playerMoney >= buyPrice;
	}
	
	public func PlayerWithdrawPayment(distance: Float) {
		let buyPrice: Int32;
		let tSystem: ref<TransactionSystem>;
		
		tSystem = GameInstance.GetTransactionSystem(this.m_player.GetGame());
		buyPrice = this.PaymentCal(distance);
		
		if buyPrice > 0 {
			tSystem.RemoveItem(this.m_player, MarketSystem.Money(), buyPrice);
			this.scheduleMSG = true;
			FasttcSG.ShowFastTravelPaidMessage(this.m_player.GetGame(), this.m_lastPaymentCal);
			this.scheduleMSG = false;
		};
	}
	
	public func GetLastPaymentCal() -> Int32 {
		return this.m_lastPaymentCal;
	}
	
	protected cb func OnLoadingScreenFinished(value: Bool) -> Bool {
		if value && this.scheduleMSG {
			FasttcSG.ShowFastTravelPaidMessage(this.m_player.GetGame(), this.m_lastPaymentCal);
			this.scheduleMSG = false;
		};
	}
}

@wrapMethod(WorldMapTooltipController)
public func SetData(const data: script_ref<WorldMapTooltipData>, menu: ref<WorldMapMenuGameController>) -> Void {
    let player: wref<GameObject> = menu.GetPlayer();
	let ftPaymentCalc: ref<TravelPayment> = GetPlayer(player.GetGame()).GetTravelPayment();
	let distance: Float;
    let fastTravelmappin: ref<FastTravelMappin>;
	let descStr: String;
	
	wrappedMethod(data, menu);
	
	fastTravelmappin = Deref(data).mappin as FastTravelMappin;
	if IsDefined(ftPaymentCalc) && IsDefined(fastTravelmappin) {
		distance = fastTravelmappin.GetDistanceToPlayer();
		descStr = GetLocalizedText("UI-MappinTypes-FastTravel");
		descStr += " : "  +  ToString(ftPaymentCalc.PaymentCal(distance) + "$");
		inkTextRef.SetText(this.m_descText, descStr);
		if Deref(data).fastTravelEnabled {
			if !ftPaymentCalc.EnoughMoney(distance) {
				inkWidgetRef.SetVisible(this.m_inputInteractContainer, false);
				inkWidgetRef.Get(this.m_descText).BindProperty(n"tintColor", n"MainColors.Red");
				inkTextRef.SetText(this.m_descText, UnAvailableMessage() + ToString(ftPaymentCalc.PaymentCal(distance)) + "$");
			} else {
				inkWidgetRef.Get(this.m_descText).BindProperty(n"tintColor", n"MainColors.Green");
				
			};
		};
	};
}

@wrapMethod(WorldMapMenuGameController)
private final func PrepFastTravel() -> Void {
    let player: ref<GameObject> = GameInstance.GetPlayerSystem(this.GetOwner().GetGame()).GetLocalPlayerMainGameObject();
	let ftPaymentCalc: ref<TravelPayment> = GetPlayer(player.GetGame()).GetTravelPayment();
	let distance: Float;
    let mappin: ref<FastTravelMappin>;

    mappin = this.selectedMappin.GetMappin() as FastTravelMappin;
	
	if !IsDefined(ftPaymentCalc) || !IsDefined(mappin) {
		wrappedMethod();
	} else {
		distance = mappin.GetDistanceToPlayer();
		if ftPaymentCalc.EnoughMoney(distance) {
			wrappedMethod();
			ftPaymentCalc.PlayerWithdrawPayment(distance);
		} else {
			GameInstance.GetAudioSystem(this.m_player.GetGame()).Play(n"ui_menu_item_crafting_fail");
		};
	};
}

@wrapMethod(PlayerPuppet)
protected cb func OnGameAttached() -> Bool {
    wrappedMethod();

    this.m_TravelPayment = new TravelPayment();
	this.m_TravelPayment.Init(this);
}

@wrapMethod(PlayerPuppet)
protected cb func OnDetach() -> Bool {
    wrappedMethod();

	this.m_TravelPayment.Uninit();
    this.m_TravelPayment = null;
}

@wrapMethod(FastTravelSystem)
private final func RequestAutoSaveWithDelay() -> Void {
	let Config = new WarpConfig();
    if Config.DisableAfterFastTravel {
        return;
    };
    wrappedMethod();
}
@wrapMethod(FastTravelSystem)
private final func RequestAutoSave() -> Void {
	let Config = new WarpConfig();
    if Config.DisableAfterFastTravel {
        return;
    };
    wrappedMethod();
}