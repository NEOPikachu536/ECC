package states;

import flixel.FlxObject;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import states.editors.MasterEditorMenu;
import options.OptionsState;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.7.3'; // This is also used for Discord RPC
	public static var fnfVersion:String = '0.2.8';
	public static var selectedPosition:FlxPoint = FlxPoint.get();

	var menuItems:Array<Array<{label:String, sprite:FlxSprite}>>;

	override function create()
	{
		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var padding = FlxG.width * 0.025;
		var blockWidth = Std.int((FlxG.width - padding * 3) * 0.5);

		var elemely = new FlxSprite().makeGraphic(blockWidth, Std.int(FlxG.height * 0.6), FlxColor.BLUE);
		elemely.x = elemely.y = padding;
		add(elemely);
		var elemelyText = new FlxText("Elemental\n(travels to Story Mode)\n\nWe need some menu assets, yo", 24);
		elemelyText.alignment = CENTER;
		elemelyText.x = elemely.x + elemely.width * 0.5 - elemelyText.width * 0.5;
		elemelyText.y = elemely.y + elemely.height * 0.5 - elemelyText.height * 0.5;
		add(elemelyText);

		var colour = new FlxSprite().makeGraphic(blockWidth, Std.int(elemely.height), FlxColor.LIME);
		colour.x = FlxG.width * 0.5125;
		colour.y = padding;
		add(colour);
		var colourText = new FlxText("Color Code\n(travels to Freeplay)", 24);
		colourText.alignment = CENTER;
		colourText.x = colour.x + colour.width * 0.5 - colourText.width * 0.5;
		colourText.y = colour.y + colour.height * 0.5 - colourText.height * 0.5;
		add(colourText);

		var gallery = new FlxSprite().makeGraphic(blockWidth, Std.int(FlxG.height - (padding * 3 + elemely.height)), FlxColor.MAGENTA);
		gallery.x = padding;
		gallery.y = FlxG.height * 0.6 + padding * 2;
		add(gallery);
		var galleryText = new FlxText("Gallery", 24);
		galleryText.x = gallery.x + gallery.width * 0.5 - galleryText.width * 0.5;
		galleryText.y = gallery.y + gallery.height * 0.5 - galleryText.height * 0.5;
		add(galleryText);

		var settings = new FlxSprite().makeGraphic(blockWidth, Std.int(gallery.height), FlxColor.ORANGE);
		settings.x = colour.x;
		settings.y = gallery.y;
		add(settings);
		var settingsText = new FlxText("Settings", 24);
		settingsText.x = settings.x + settings.width * 0.5 - settingsText.width * 0.5;
		settingsText.y = settings.y + settings.height * 0.5 - settingsText.height * 0.5;
		add(settingsText);

		menuItems = [
			[{label: "elemental", sprite: elemely}, {label: "color-code", sprite: colour}],
			[{label: "gallery", sprite: gallery}, {label: "settings", sprite: settings}]
		];

		var psychVer:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		psychVer.scrollFactor.set();
		psychVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(psychVer);
		var fnfVer:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + fnfVersion, 12);
		// Application.current.meta.get('version')
		fnfVer.scrollFactor.set();
		fnfVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(fnfVer);
		changeItem(0, 0);

		#if ACHIEVEMENTS_ALLOWED
		// Unlocks "Freaky on a Friday Night" achievement if it's a Friday and between 18:00 PM and 23:59 PM
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18)
			Achievements.unlock('friday_night_play');

		#if MODS_ALLOWED
		Achievements.reloadList();
		#end
		#end

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if(FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
			if (FreeplayState.vocals != null)
				FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		if(!selectedSomethin)
		{
			if(controls.UI_UP_P)
				changeItem(0, -1);

			if(controls.UI_DOWN_P)
				changeItem(0, 1);

			if(controls.UI_LEFT_P)
				changeItem(-1, 0);

			if(controls.UI_RIGHT_P)
				changeItem(1, 0);

			if(controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if(controls.ACCEPT)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));
				/*
					// I will bring this back if possible
					if (optionShit[curSelected] == 'donate')
					{
						CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
					}
					else
				*/
				{
					selectedSomethin = true;

					var x = Std.int(selectedPosition.x);
					var y = Std.int(selectedPosition.y);
					var item = menuItems[y][x];
					FlxFlicker.flicker(item.sprite, 1, 0.06, false, false, function(flick:FlxFlicker)
					{
						switch(item.label)
						{
							case 'elemental':
								MusicBeatState.switchState(new StoryMenuState());
							case 'color-code':
								MusicBeatState.switchState(new FreeplayState());

							#if MODS_ALLOWED
							case 'mods':
								MusicBeatState.switchState(new ModsMenuState());
							#end

							#if ACHIEVEMENTS_ALLOWED
							case 'awards':
								MusicBeatState.switchState(new AchievementsMenuState());
							#end

							case 'gallery':
								MusicBeatState.switchState(new CreditsState());
							case 'settings':
								MusicBeatState.switchState(new OptionsState());
								OptionsState.onPlayState = false;
								if (PlayState.SONG != null)
								{
									PlayState.SONG.arrowSkin = null;
									PlayState.SONG.splashSkin = null;
									PlayState.stageUI = 'normal';
								}
						}
					});
				}
			}
			#if desktop
			if (controls.justPressed('debug_1'))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);
	}

	function changeItem(xInc:Int, yInc:Int):Void
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));

		var curX = Std.int(selectedPosition.x);
		var curY = Std.int(selectedPosition.y);

		var item = menuItems[curY][curX].sprite;
		item.color = FlxColor.WHITE;
		// item.animation.play('idle');
		// item.updateHitbox();
		// item.screenCenter(X);

		var newX = FlxMath.wrap(curX + xInc, 0, menuItems[0].length - 1); // To do: make this care about row
		var newY = FlxMath.wrap(curY + yInc, 0, menuItems.length - 1);

		var item = menuItems[newY][newX].sprite;
		item.color = 0xFF808080;
		// item.animation.play('selected'); // Will do when exists
		// item.centerOffsets();
		// item.screenCenter(X);

		selectedPosition.set(newX, newY);
	}

	override public function destroy():Void
	{
		super.destroy();

		menuItems = null;
	}
}
