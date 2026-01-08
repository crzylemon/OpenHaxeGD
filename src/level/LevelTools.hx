// Contributions:
// Crzy (crzylemon)
// Source:
// Project Reversio
package level;

class LevelTools {
    public static function getLevel(levelId: Int, someBool: Bool = false): GJGameLevel {
        var result = new GJGameLevel();
        
        switch (levelId) {
            case 1: // Stereo Madness
                result.setLevelName(LevelTools.getAudioTitle(0));
                result.setSongID(0);
                result.setDifficulty(1);
                result.setStars(1);
                result.setCapacityString("29_98_29_40_29_29_29_29_29_29_177_29_73_29_29_29");
                
            case 2: // Back On Track
                result.setLevelName(LevelTools.getAudioTitle(1));
                result.setSongID(1);
                result.setDifficulty(1);
                result.setStars(2);
                result.setCapacityString("29_54_29_40_29_29_29_29_29_29_98_29_54_29_29_29");
                
            case 3: // Polargeist
                result.setLevelName(LevelTools.getAudioTitle(2));
                result.setSongID(2);
                result.setDifficulty(2);
                result.setStars(3);
                result.setCapacityString("29_98_29_40_29_29_29_29_29_29_29_29_98_29_29_29");
                
            case 4: // Dry Out
                result.setLevelName(LevelTools.getAudioTitle(3));
                result.setSongID(3);
                result.setDifficulty(2);
                result.setStars(4);
                result.setCapacityString("29_73_29_40_29_29_29_29_29_29_73_29_73_29_29_29");
                
            case 5: // Base After Base
                result.setLevelName(LevelTools.getAudioTitle(4));
                result.setSongID(4);
                result.setDifficulty(3);
                result.setStars(5);
                result.setCapacityString("29_73_29_40_29_29_29_29_29_29_98_29_73_29_29_29");
                
            case 6: // Cant Let Go
                result.setLevelName(LevelTools.getAudioTitle(5));
                result.setSongID(5);
                result.setDifficulty(3);
                result.setStars(6);
                result.setCapacityString("29_73_29_40_29_29_29_29_29_29_29_29_73_29_29_29");
                
            case 7: // Jumper
                result.setLevelName(LevelTools.getAudioTitle(6));
                result.setSongID(6);
                result.setDifficulty(4);
                result.setStars(7);
                result.setCapacityString("29_98_29_40_29_29_29_29_29_29_98_29_98_29_29_29");
                
            case 8: // Time Machine
                result.setLevelName(LevelTools.getAudioTitle(7));
                result.setSongID(7);
                result.setDifficulty(4);
                result.setStars(8);
                result.setCapacityString("29_132_29_40_29_29_29_29_29_29_73_29_98_29_29_29");
                
            case 9: // Cycles
                result.setLevelName(LevelTools.getAudioTitle(8));
                result.setSongID(8);
                result.setDifficulty(4);
                result.setStars(9);
                result.setCapacityString("29_98_29_40_29_29_29_40_29_29_98_29_98_29_29_29");
                
            case 10: // xStep
                result.setLevelName(LevelTools.getAudioTitle(9));
                result.setSongID(9);
                result.setDifficulty(5);
                result.setStars(10);
                result.setCapacityString("29_132_29_40_29_29_29_54_29_29_132_29_73_29_29_29");
                
            case 11: // Clutterfunk
                result.setLevelName(LevelTools.getAudioTitle(10));
                result.setSongID(10);
                result.setDifficulty(5);
                result.setStars(11);
                result.setCapacityString("29_237_29_40_29_29_29_73_29_29_29_29_98_29_29_29");
                
            case 12: // Theory of Everything
                result.setLevelName(LevelTools.getAudioTitle(11));
                result.setSongID(11);
                result.setDifficulty(5);
                result.setStars(12);
                result.setCapacityString("29_237_29_54_29_29_29_73_29_29_132_29_132_29_29_29");
                
            case 13: // Electroman Adventures
                result.setLevelName(LevelTools.getAudioTitle(12));
                result.setSongID(12);
                result.setDifficulty(5);
                result.setStars(10);
                result.setCapacityString("29_237_29_40_29_29_29_98_29_29_98_29_132_29_29_29");
                
            case 14: // Clubstep
                result.setLevelName(LevelTools.getAudioTitle(13));
                result.setSongID(13);
                result.setDifficulty(6);
                result.setStars(14);
                result.setCoinsRequired(10);
                result.setDemon(1);
                result.setCapacityString("29_237_29_54_29_29_29_132_29_29_98_29_132_29_29_29");
                
            case 15: // Electrodynamix
                result.setLevelName(LevelTools.getAudioTitle(14));
                result.setSongID(14);
                result.setDifficulty(5);
                result.setStars(12);
                result.setCapacityString("29_237_98_40_29_29_29_237_29_29_98_73_177_29_29_29");
                
            case 16: // Hexagon Force
                result.setLevelName(LevelTools.getAudioTitle(15));
                result.setSongID(15);
                result.setDifficulty(5);
                result.setStars(12);
                result.setCapacityString("29_317_73_73_29_29_54_132_29_29_237_132_177_29_29_29");
                
            case 17: // Blast Processing
                result.setLevelName(LevelTools.getAudioTitle(16));
                result.setSongID(16);
                result.setDifficulty(4);
                result.setStars(10);
                result.setCapacityString("29_237_29_73_29_29_98_132_29_29_566_54_132_29_29_29");
                
            case 18: // Theory of Everything 2
                result.setLevelName(LevelTools.getAudioTitle(17));
                result.setSongID(17);
                result.setDifficulty(6);
                result.setStars(14);
                result.setCoinsRequired(20);
                result.setDemon(1);
                result.setCapacityString("29_317_40_54_29_40_132_132_29_29_424_98_237_29_29_29");
                
            case 19: // Geometrical Dominator
                result.setLevelName(LevelTools.getAudioTitle(18));
                result.setSongID(18);
                result.setDifficulty(4);
                result.setStars(10);
                result.setCapacityString("29_424_132_40_29_29_566_132_29_29_756_237_132_29_73_29");
                
            case 20: // Deadlocked
                result.setLevelName(LevelTools.getAudioTitle(19));
                result.setSongID(19);
                result.setDifficulty(6);
                result.setStars(15);
                result.setCoinsRequired(30);
                result.setDemon(1);
                result.setCapacityString("29_317_73_73_29_29_317_424_73_29_566_317_177_29_132_54");
                
            case 21: // Fingerdash
                result.setLevelName(LevelTools.getAudioTitle(20));
                result.setSongID(20);
                result.setDifficulty(5);
                result.setStars(12);
                
            case 3001: // Secret
                result.setLevelName("The Challenge");
                result.setSongID(24);
                result.setDifficulty(3);
                result.setStars(3);
                result.setCapacityString("73_237_29_40_29_29_237_98_29_29_237_237_132_29_29_29");
        }
        
        return result;
    }
    
    public static function getAudioTitle(songId: Int): String {
        return switch (songId) {
            case -1: return "Practice: Stay Inside Me";
            case 0: return "Stereo Madness";
            case 1: return "Back On Track";
            case 2: return "Polargeist";
            case 3: return "Dry Out";
            case 4: return "Base After Base";
            case 5: return "Cant Let Go";
            case 6: return "Jumper";
            case 7: return "Time Machine";
            case 8: return "Cycles";
            case 9: return "xStep";
            case 10: return "Clutterfunk";
            case 11: return "Theory of Everything";
            case 12: return "Electroman Adventures";
            case 13: return "Clubstep";
            case 14: return "Electrodynamix";
            case 15: return "Hexagon Force";
            case 16: return "Blast Processing";
            case 17: return "Theory of Everything 2";
            case 18: return "Geometrical Dominator";
            case 19: return "Deadlocked";
            case 20: return "Fingerdash";
            case 21: return "The Seven Seas";
            case 22: return "Viking Arena";
            case 23: return "Airborne Robots";
            case 24: return "Secret";
            case 25: return "Payload";
            case 26: return "Beast Mode";
            case 27: return "Machina";
            case 28: return "Years";
            case 29: return "Frontlines";
            case 30: return "Space Pirates";
            case 31: return "Striker";
            case 32: return "Embers";
            case 33: return "Round 1";
            case 34: return "Monster Dance Off";
            case 35: return "Press Start";
            case 36: return "Nock Em";
            case 37: return "Power Trip";
            default: return "Unknown";
        }
    }
}