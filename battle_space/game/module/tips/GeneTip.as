package game.module.tips
{
	import game.global.event.GuildEvent;
	import game.global.vo.User;
	import MornUI.tips.GeneTipUI;
	
	import game.common.AnimationUtil;
	import game.common.LayerManager;
	import game.common.UIRegisteredMgr;
	import game.common.XFacade;
	import game.common.XUtils;
	import game.common.base.BaseView;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.consts.ItemConst;
	import game.global.data.DBGeneList;
	import game.global.data.DBGeneSuit;
	import game.global.data.DBItem;
	import game.global.data.bag.ItemData;
	import game.global.event.Signal;
	import game.global.util.ItemUtil;
	import game.global.vo.ItemVo;
	import game.module.gene.GenEnhanceView;
	
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.html.dom.HTMLDivElement;
	
	/**
	 * GeneTip
	 * author:huhaiming
	 * GeneTip.as 2017-3-28 上午10:39:16
	 * version 1.0
	 *
	 */
	public class GeneTip extends BaseView
	{
		private var _data:Object;
		private var _type:String;
		/**类型--常量-装备*/
		public static const EQUIP:String = "eq";
		/**类型-常量-卸装*/
		public static const TAKEOFF:String = "off"
		/**类型-常量-展示*/
		public static const ONLY_SHOW:String = "show"
		/**常量-属性数量*/
		private const PRO_NUM:int = 3;
		
		/**
		 * 是否可以点击舞台关闭
		 */
		private var _canStageClose:Boolean = true;
		public function GeneTip()
		{
			super();
			this._m_iLayerType = LayerManager.M_TIP;
			this._m_iPositionType = LayerManager.CENTER;
		}
		
		private function onClick(event:Event):void{
			switch(event.target){
				case view.btn_1:
					XFacade.instance.openModule("GenEnhanceView", _data);
					this.close();
					break;
				case view.btn_0:
					if(_type == EQUIP){
						Signal.intance.event(EQUIP,_data);
					}else{
						Signal.intance.event(TAKEOFF,_data);
					}
					this.close();
					break;
			}
		}
		
		private function onStageClick(e:Event):void {
			
			if (User.getInstance().forbidBlankClose || User.getInstance().isInGuilding)
			{
				return;
			}
			
			var target:Sprite = view.bg;
			if(view.bg1.visible){
				target = view.bg1;
			}
			if(!target.hitTestPoint(e.stageX,e.stageY)){
				this.close();
			}
		}
		
		override public function show(...args):void{
			super.show();
			_data = args[0][0];
			_type = args[0][1];
			var dH:Number = 0;
			//默认为装备状态
			if(_type == ONLY_SHOW){
				view.btnBox.visible = false;
				view.bg.visible = false;
				view.bg1.visible = true;
			}else{
				view.bg.visible = true;
				view.bg1.visible = false;
				view.btnBox.visible = true;
				if(!_type){
					_type = EQUIP;
					//view.btn_0.skin = "common/buttons/btn_equip.png";
					view.labelTF.text = GameLanguage.getLangByKey("L_A_38019")
					view.priceIcon.visible = view.priceTf.visible = false
				}else{
					//view.btn_0.skin = "common/buttons/btn_down.png";
					view.labelTF.text = GameLanguage.getLangByKey("L_A_38020")
					view.priceIcon.visible = view.priceTf.visible = true;
				}
			}
			
			_canStageClose = true;
			//trace("This is -------------------------",_data);
			
			var vo:ItemVo
			var geneInfo:Object 
			
			if(_data is ItemData){
				vo = _data.vo;
				geneInfo = DBGeneList.getGeneInfoByItemId(_data.iid,_data.exPro.level);
			}else{
				geneInfo = DBGeneList.getGeneInfoByItemId(_data.genenId,_data.level);
				vo = GameConfigManager.items_dic[geneInfo.type]
			}
			trace("genInfo---------------------------------",geneInfo,vo);
			var itemVo:ItemVo = DBItem.getItemData(geneInfo.type);
			if(itemVo){
				view.iconBg.skin = "common/i"+(itemVo.quality-1)+".png"
			}
			view.nameTF.text = vo.name+"";
			view.lvTF.text = GameLanguage.getLangByKey("L_A_73")+geneInfo.level;
			view.priceTf.text = (geneInfo.cost+"").split("=")[1];
			ItemUtil.formatIcon(view.priceIcon, geneInfo.cost);
			
			
			var pro:Object = DBGeneList.parsePro(geneInfo.attribute);
			var index:int = 0;
			for(var i:String in pro){
				view["p"+index].skin = "common/icons/"+XUtils.getIconName(i)+".png";
				view["valueTF_"+index].text = pro[i]+"";
				view["p"+index].visible = true;
				view["valueTF_"+index].visible = true;
				index ++;
				//
				if(index >= PRO_NUM){
					break;
				}
			}
			if(index == 0){
				view.proBG.height = (view["p0"].y - view.proBG.y) + 44//
			}else{
				view.proBG.height = (view["p"+(index-1)].y - view.proBG.y) + 44//
			}
			for(var j:int = index; j<PRO_NUM; j++){
				view["p"+j].visible = false
				view["valueTF_"+j].visible = false
			}
			
			
			//特殊处理经验基因
			if(vo.subType == ItemConst.GENE_STYPE_4){
				view["p"+0].skin = "common/icons/exp.png";
				view["valueTF_"+0].text = geneInfo.base_exp+"";
				view["p"+0].visible = true;
				view["valueTF_"+0].visible = true;
			}
			
			dH = view.proBG.y + view.proBG.height+10;
			
			var proNum:int=0;
			var suitStr:String = DBGeneSuit.getSuitInfo(geneInfo.suit_id,2);
			if(vo.subType == ItemConst.GENE_STYPE_4){
				suitStr = '';
			}
			if(suitStr){
				this.view.suit2Box.visible = true;
				this.view.suit2Box.y = dH;
				pro = DBGeneList.parsePro(suitStr);
				for(i in pro){
					view["sicon_"+proNum].visible = true;
					view["sicon_"+proNum].skin = "common/icons/"+XUtils.getIconName(i)+".png";
					view["svTF_"+proNum].text = pro[i]+"";
					proNum ++; 
					break;
				}
				if(proNum == 1){
					view.suitBG0.height = 49;
				}else{
					view.suitBG0.height = 69;
				}
				dH += view.suit2Box.height+5;
			}else{
				this.view.suit2Box.visible = false;
			}
			
			//三件套属性 ===================================
			proNum = 0;
			suitStr = DBGeneSuit.getSuitInfo(geneInfo.suit_id,3);
			if(vo.subType == ItemConst.GENE_STYPE_4){
				suitStr = '';
			}
			if(suitStr){
				this.view.suit3Box.visible = true;
				this.view.suit3Box.y = dH;
				pro = DBGeneList.parsePro(suitStr);
				for(i in pro){
					view["sicon_"+proNum+"1"].visible = true;
					view["sicon_"+proNum+"1"].skin = "common/icons/"+XUtils.getIconName(i)+".png";
					view["svTF_"+proNum+"1"].text = pro[i]+"";
					proNum ++
					break;
				}
				if(proNum == 1){
					view.suitBG01.height = 49;
				}else{
					view.suitBG01.height = 69;
				}
				dH += this.view.suit3Box.height+5;
			}else{
				this.view.suit3Box.visible = false;
			}
			
			
			if(view.btnBox.visible){
				this.view.bg.height = Math.max(320, dH+85);
			}else{
				this.view.bg1.height = Math.max(260, dH+30);
				//this.view.bg.height = Math.max(402, dH);
			}
			view.btnBox.y = this.view.bg.height - view.btnBox.height-10;
			if(this.view.bg.visible){
				this.height = this.view.bg.height;
			}else{
				this.height = this.view.bg1.height;
			}
			
			
			view.icon.graphics.clear();
			view.icon.loadImage("appRes/icon/itemIcon/"+vo.icon+".png");
			
		}
		
		override public function close():void{
			_data = null;
			super.close();
		}
		
		override public function createUI():void{
			this._view = new GeneTipUI();
			this.addChild(this._view);
			
			UIRegisteredMgr.AddUI(view.btn_0,"EquipGene");
			UIRegisteredMgr.AddUI(view.btn_1,"EnhanceGene");
			
		}
		
		override public function addEvent():void{
			view.on(Event.CLICK, this, this.onClick);
			Laya.stage.on(Event.MOUSE_DOWN, this, this.onStageClick);
			
			super.addEvent();
		}
		
		override public function removeEvent():void{
			view.off(Event.CLICK, this, this.onClick);
			Laya.stage.off(Event.MOUSE_DOWN, this, this.onStageClick);
			super.addEvent();
		}
		
		private function get view():GeneTipUI{
			return _view as GeneTipUI;
		}
	}
}