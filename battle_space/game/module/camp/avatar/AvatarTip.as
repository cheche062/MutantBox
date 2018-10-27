package game.module.camp.avatar
{
	import MornUI.camp.avatar.AvatarTipUI;
	import MornUI.componets.SkillItemUI;
	
	import game.common.LayerManager;
	import game.common.XFacade;
	import game.common.XTipManager;
	import game.common.XUtils;
	import game.common.base.BaseDialog;
	import game.global.GameConfigManager;
	import game.global.GameLanguage;
	import game.global.vo.SkillVo;
	import game.module.camp.CampData;
	import game.module.camp.CampView;
	import game.module.camp.NewUnitInfoView;
	import game.module.camp.UnitInfoView;
	import game.module.camp.UnitSrcView;
	import game.module.tips.SkillTip;
	
	import laya.events.Event;
	import laya.net.URL;
	
	/**
	 * AvatarTip
	 * author:huhaiming
	 * AvatarTip.as 2018-4-3 下午2:57:05
	 * version 1.0
	 *
	 */
	public class AvatarTip extends BaseDialog
	{
		private var _data:SkinVo;
		private var _pro:SkinProVo;
		private static var POS:Array = [516, 430];
		private static var SIZE_H:Array = [607, 530]
		public function AvatarTip()
		{
			super();
			//this._m_iLayerType = LayerManager.M_TIP;
			this._m_iPositionType = LayerManager.CENTER;
			this.bg.alpha = 0.01;
		}
		
		override public function show(...args):void{
			super.show();
			var vo:SkinVo = args[0];
			_data = vo;
			
			
			var hero:Object = CampData.getUintById(vo.unit);
			var lv:int = 0;
			if(hero && hero.skins && hero.skins[vo.ID]){
				lv = hero.skins[vo.ID][0];
			}
			view.tfName.text = GameLanguage.getLangByKey(vo.name)+" "+GameLanguage.getLangByKey("L_A_73")+lv;
			
			var skinPro:SkinProVo = DBSkin.getSkinPro(lv, vo.node);
			_pro = skinPro
			var arr:Array;
			if(skinPro){
				view.tfBaseBr.text = skinPro.base_br+"";
				view.tfExBr.text = skinPro.strength_br+"";
				//view.tfBaseBr.x = view.lbB.x+view.lbB.textField.textWidth+4;
				//view.tfExBr.x = view.lbE.x+view.lbE.textField.textWidth+4;
				if(skinPro.value1){
					arr = skinPro.value1.split("|");
					AvatarLvUpView.formatPro(arr[0], view.base_0);
					AvatarLvUpView.formatPro(arr[1], view.base_1);
				}else{
					AvatarLvUpView.formatPro(null, view.base_0);
					AvatarLvUpView.formatPro(null, view.base_1);
				}
				
				if(skinPro.value2){
					arr = skinPro.value2.split("|");
					AvatarLvUpView.formatPro(arr[0], view.ex_0);
					AvatarLvUpView.formatPro(arr[1], view.ex_1);
					AvatarLvUpView.formatPro(arr[2], view.ex_2);
					AvatarLvUpView.formatPro(arr[3], view.ex_3);
				}else{
					AvatarLvUpView.formatPro(null, view.ex_0);
					AvatarLvUpView.formatPro(null, view.ex_1);
					AvatarLvUpView.formatPro(null, view.ex_2);
					AvatarLvUpView.formatPro(null, view.ex_3);
				}
				
				if(_data.skill){
					view.skillItem.visible = true;
					formatSkill(view.skillItem, _data.skill);
					view.skillLb.visible = true;
					view.bg.height = SIZE_H[0];
					view.spBtn.y = POS[0];
					view.height = SIZE_H[0]
					view.skillItem.gray = (lv == 0)
				}else{
					view.skillItem.visible = false;
					view.skillLb.visible = false;
					view.bg.height = SIZE_H[1];
					view.spBtn.y = POS[1];
					view.height = SIZE_H[1]
				}
				view.btnGet.visible = true;
			}else{
				view.tfBaseBr.text = "";
				view.tfExBr.text = "";
				AvatarLvUpView.formatPro(null, view.base_0);
				AvatarLvUpView.formatPro(null, view.base_1);
				
				AvatarLvUpView.formatPro(null, view.ex_0);
				AvatarLvUpView.formatPro(null, view.ex_1);
				AvatarLvUpView.formatPro(null, view.ex_2);
				AvatarLvUpView.formatPro(null, view.ex_3);
				view.skillItem.visible = false;
				view.btnGet.visible = false;
			}
		}
		
		private function onClick(e:Event):void{
			switch(e.target){
				case view.btnClose:
					this.close();
					break;
				case view.btnGet:
					XFacade.instance.showModule(SkinSrcView, _data, function() {
						XFacade.instance.closeModule(CampView);
						XFacade.instance.closeModule(UnitInfoView);
						XFacade.instance.closeModule(NewUnitInfoView);
						XFacade.instance.closeModule(AvatarLvUpView);
					});
					this.close();
					break;
				default:
					if(XUtils.checkHit(view.skillItem)){
						var skillId:String = _data.skill.split("=")[1];
						XTipManager.showTip([skillId],SkillTip, false);
					}
					break;
			}
		}
		
		private function formatSkill(item:SkillItemUI, skillId:*):void{
			if(skillId && skillId != "undefined"){
				skillId = (skillId+"").split("=")[1];
				item.visible = true;
				var vo:SkillVo = GameConfigManager.unit_skill_dic[skillId];
				trace("vo::::::",vo)
				item.skillBg.skin = "common/skill_bg.png";
				item.lvBG.skin = "common/skill_bg_1.png";
				item.lvTF.text = vo.skill_level+"";
				
				if(vo){
					item.nameTF.text = vo.skill_name+"";
					item.icon.skin = URL.formatURL("appRes/icon/skillIcon/"+vo.skill_icon+".png");
				}else{
					item.nameTF.text = ""
				}
			}else{
				item.visible = false;
			}
		}
		
		override public function createUI():void{
			this._view = new AvatarTipUI();
			this.addChild(_view);
			this.closeOnBlank = true;
		}
		
		override public function addEvent():void{
			super.addEvent();
			view.on(Event.CLICK, this, this.onClick);
		}
		
		override public function removeEvent():void{
			super.removeEvent();
			view.off(Event.CLICK, this, this.onClick);
		}
		
		private function get view():AvatarTipUI{
			return _view;
		}
	}
}