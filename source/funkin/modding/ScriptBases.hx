package funkin.modding;

import polymod.hscript.HScriptedClass;

//
// SCRIPTED
//

@:hscriptClass
class ScriptedLevel extends funkin.ui.story.Level implements HScriptedClass {}

@:hscriptClass
class ScriptedSong extends funkin.play.song.Song implements HScriptedClass {}

@:hscriptClass
class ScriptedCharacter extends funkin.play.character.Character implements HScriptedClass {}

@:hscriptClass
class ScriptedStage extends funkin.play.stage.Stage implements HScriptedClass {}

@:hscriptClass
class ScriptedStageProp extends funkin.play.stage.StageProp implements HScriptedClass {}

@:hscriptClass
class ScriptedSongEvent extends funkin.play.song.SongEvent implements HScriptedClass {}

@:hscriptClass
class ScriptedNoteKind extends funkin.play.note.NoteKind implements HScriptedClass {}

@:hscriptClass
class ScriptedStyle extends funkin.play.Style implements HScriptedClass {}

@:hscriptClass
class ScriptedBaseCutscene extends funkin.play.cutscene.BaseCutscene implements HScriptedClass {}

@:hscriptClass
class ScriptedStickerPack extends funkin.ui.sticker.StickerPack implements HScriptedClass {}

@:hscriptClass
class ScriptedAlbum extends funkin.ui.freeplay.album.Album implements HScriptedClass {}

@:hscriptClass
class ScriptedModule extends funkin.modding.module.Module implements HScriptedClass {}

//
// MISC
//

@:hscriptClass
class ScriptedFunkinBar extends funkin.graphics.FunkinBar implements HScriptedClass {}

@:hscriptClass
class ScriptedFunkinSprite extends funkin.graphics.FunkinSprite implements HScriptedClass {}

@:hscriptClass
class ScriptedFunkinText extends funkin.graphics.FunkinText implements HScriptedClass {}

@:hscriptClass
class ScriptedSelectorText extends funkin.ui.selector.SelectorText implements HScriptedClass {}

@:hscriptClass
class ScriptedFunkinState extends funkin.ui.FunkinState implements HScriptedClass {}

@:hscriptClass
class ScriptedFunkinSubState extends funkin.ui.FunkinSubState implements HScriptedClass {}

@:hscriptClass
class ScriptedMenuList extends funkin.ui.MenuList implements HScriptedClass {}

@:hscriptClass
class ScriptedStateMachine extends funkin.ui.StateMachine implements HScriptedClass {}

//
// FLIXEL
//

@:hscriptClass
class ScriptedFlxCamera extends flixel.FlxCamera implements HScriptedClass {}

@:hscriptClass
class ScriptedFlxSprite extends flixel.FlxSprite implements HScriptedClass {}

@:hscriptClass
class ScriptedFlxState extends flixel.FlxState implements HScriptedClass {}

@:hscriptClass
class ScriptedFlxSubState extends flixel.FlxSubState implements HScriptedClass {}

@:hscriptClass
class ScriptedFlxTypedGroup extends flixel.group.FlxGroup.FlxTypedGroup<Dynamic> implements HScriptedClass {}

@:hscriptClass
class ScriptedFlxTypedSpriteGroup extends flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup<Dynamic> implements HScriptedClass {}

@:hscriptClass
class ScriptedFlxSound extends flixel.sound.FlxSound implements HScriptedClass {}

@:hscriptClass
class ScriptedFlxText extends flixel.text.FlxText implements HScriptedClass {}

@:hscriptClass
class ScriptedFlxBitmapText extends flixel.text.FlxBitmapText implements HScriptedClass {}
