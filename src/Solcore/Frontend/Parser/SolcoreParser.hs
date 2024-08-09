{-# OPTIONS_GHC -w #-}
module Solcore.Frontend.Parser.SolcoreParser where

import Solcore.Frontend.Lexer.SolcoreLexer hiding (lexer)
import Solcore.Frontend.Syntax.Contract
import Solcore.Frontend.Syntax.Name
import Solcore.Frontend.Syntax.Stmt
import Solcore.Frontend.Syntax.Ty
import Solcore.Primitives.Primitives
import Language.Yul
import qualified Data.Array as Happy_Data_Array
import qualified Data.Bits as Bits
import Control.Applicative(Applicative(..))
import Control.Monad (ap)

-- parser produced by Happy Version 1.20.1.1

data HappyAbsSyn 
	= HappyTerminal (Token)
	| HappyErrorToken Prelude.Int
	| HappyAbsSyn4 (CompUnit Name)
	| HappyAbsSyn5 ([Import])
	| HappyAbsSyn6 (Import)
	| HappyAbsSyn7 ([TopDecl Name])
	| HappyAbsSyn8 (TopDecl Name)
	| HappyAbsSyn9 (Contract Name)
	| HappyAbsSyn10 ([ContractDecl Name])
	| HappyAbsSyn11 (ContractDecl Name)
	| HappyAbsSyn12 (TySym)
	| HappyAbsSyn13 (Field Name)
	| HappyAbsSyn14 (DataTy)
	| HappyAbsSyn15 ([Constr])
	| HappyAbsSyn16 (Constr)
	| HappyAbsSyn17 (Class Name)
	| HappyAbsSyn18 ([Signature Name])
	| HappyAbsSyn19 ([Tyvar])
	| HappyAbsSyn21 ([Pred])
	| HappyAbsSyn24 (Pred)
	| HappyAbsSyn26 (Signature Name)
	| HappyAbsSyn28 ([Param Name])
	| HappyAbsSyn29 (Param Name)
	| HappyAbsSyn30 (Instance Name)
	| HappyAbsSyn31 ([Ty])
	| HappyAbsSyn33 ([FunDef Name])
	| HappyAbsSyn35 (FunDef Name)
	| HappyAbsSyn36 (Maybe Ty)
	| HappyAbsSyn37 (Constructor Name)
	| HappyAbsSyn38 ([Stmt Name])
	| HappyAbsSyn40 (Stmt Name)
	| HappyAbsSyn41 ([Exp Name])
	| HappyAbsSyn42 (Maybe (Exp Name))
	| HappyAbsSyn43 (Exp Name)
	| HappyAbsSyn47 ([([Pat Name], [Stmt Name])])
	| HappyAbsSyn48 (([Pat Name], [Stmt Name]))
	| HappyAbsSyn49 ([Pat Name])
	| HappyAbsSyn50 (Pat Name)
	| HappyAbsSyn53 (Literal)
	| HappyAbsSyn54 (Ty)
	| HappyAbsSyn55 (([Ty], Ty))
	| HappyAbsSyn56 (Tyvar)
	| HappyAbsSyn57 (Name)
	| HappyAbsSyn58 ([Name])
	| HappyAbsSyn60 (YulBlock)
	| HappyAbsSyn62 ([YulStmt])
	| HappyAbsSyn63 (YulStmt)
	| HappyAbsSyn66 (YulCases)
	| HappyAbsSyn67 ((YLiteral, YulBlock))
	| HappyAbsSyn68 (Maybe YulBlock)
	| HappyAbsSyn71 (Maybe YulExp)
	| HappyAbsSyn74 (YulExp)
	| HappyAbsSyn75 ([YulExp])
	| HappyAbsSyn77 (YLiteral)
	| HappyAbsSyn78 (())

{- to allow type-synonyms as our monads (likely
 - with explicitly-specified bind and return)
 - in Haskell98, it seems that with
 - /type M a = .../, then /(HappyReduction M)/
 - is not allowed.  But Happy is a
 - code-generator that can just substitute it.
type HappyReduction m = 
	   Prelude.Int 
	-> (Token)
	-> HappyState (Token) (HappyStk HappyAbsSyn -> m HappyAbsSyn)
	-> [HappyState (Token) (HappyStk HappyAbsSyn -> m HappyAbsSyn)] 
	-> HappyStk HappyAbsSyn 
	-> m HappyAbsSyn
-}

action_0,
 action_1,
 action_2,
 action_3,
 action_4,
 action_5,
 action_6,
 action_7,
 action_8,
 action_9,
 action_10,
 action_11,
 action_12,
 action_13,
 action_14,
 action_15,
 action_16,
 action_17,
 action_18,
 action_19,
 action_20,
 action_21,
 action_22,
 action_23,
 action_24,
 action_25,
 action_26,
 action_27,
 action_28,
 action_29,
 action_30,
 action_31,
 action_32,
 action_33,
 action_34,
 action_35,
 action_36,
 action_37,
 action_38,
 action_39,
 action_40,
 action_41,
 action_42,
 action_43,
 action_44,
 action_45,
 action_46,
 action_47,
 action_48,
 action_49,
 action_50,
 action_51,
 action_52,
 action_53,
 action_54,
 action_55,
 action_56,
 action_57,
 action_58,
 action_59,
 action_60,
 action_61,
 action_62,
 action_63,
 action_64,
 action_65,
 action_66,
 action_67,
 action_68,
 action_69,
 action_70,
 action_71,
 action_72,
 action_73,
 action_74,
 action_75,
 action_76,
 action_77,
 action_78,
 action_79,
 action_80,
 action_81,
 action_82,
 action_83,
 action_84,
 action_85,
 action_86,
 action_87,
 action_88,
 action_89,
 action_90,
 action_91,
 action_92,
 action_93,
 action_94,
 action_95,
 action_96,
 action_97,
 action_98,
 action_99,
 action_100,
 action_101,
 action_102,
 action_103,
 action_104,
 action_105,
 action_106,
 action_107,
 action_108,
 action_109,
 action_110,
 action_111,
 action_112,
 action_113,
 action_114,
 action_115,
 action_116,
 action_117,
 action_118,
 action_119,
 action_120,
 action_121,
 action_122,
 action_123,
 action_124,
 action_125,
 action_126,
 action_127,
 action_128,
 action_129,
 action_130,
 action_131,
 action_132,
 action_133,
 action_134,
 action_135,
 action_136,
 action_137,
 action_138,
 action_139,
 action_140,
 action_141,
 action_142,
 action_143,
 action_144,
 action_145,
 action_146,
 action_147,
 action_148,
 action_149,
 action_150,
 action_151,
 action_152,
 action_153,
 action_154,
 action_155,
 action_156,
 action_157,
 action_158,
 action_159,
 action_160,
 action_161,
 action_162,
 action_163,
 action_164,
 action_165,
 action_166,
 action_167,
 action_168,
 action_169,
 action_170,
 action_171,
 action_172,
 action_173,
 action_174,
 action_175,
 action_176,
 action_177,
 action_178,
 action_179,
 action_180,
 action_181,
 action_182,
 action_183,
 action_184,
 action_185,
 action_186,
 action_187,
 action_188,
 action_189,
 action_190,
 action_191,
 action_192,
 action_193,
 action_194,
 action_195,
 action_196,
 action_197,
 action_198,
 action_199,
 action_200,
 action_201,
 action_202,
 action_203,
 action_204,
 action_205,
 action_206,
 action_207,
 action_208,
 action_209,
 action_210,
 action_211,
 action_212,
 action_213,
 action_214,
 action_215,
 action_216,
 action_217,
 action_218,
 action_219,
 action_220,
 action_221,
 action_222,
 action_223,
 action_224,
 action_225,
 action_226,
 action_227,
 action_228,
 action_229,
 action_230,
 action_231,
 action_232,
 action_233,
 action_234,
 action_235,
 action_236,
 action_237,
 action_238,
 action_239,
 action_240,
 action_241,
 action_242,
 action_243,
 action_244,
 action_245,
 action_246,
 action_247,
 action_248,
 action_249,
 action_250,
 action_251,
 action_252,
 action_253,
 action_254,
 action_255,
 action_256,
 action_257,
 action_258,
 action_259,
 action_260,
 action_261,
 action_262,
 action_263,
 action_264,
 action_265,
 action_266,
 action_267,
 action_268,
 action_269,
 action_270,
 action_271,
 action_272,
 action_273,
 action_274,
 action_275,
 action_276 :: () => Prelude.Int -> ({-HappyReduction (Alex) = -}
	   Prelude.Int 
	-> (Token)
	-> HappyState (Token) (HappyStk HappyAbsSyn -> (Alex) HappyAbsSyn)
	-> [HappyState (Token) (HappyStk HappyAbsSyn -> (Alex) HappyAbsSyn)] 
	-> HappyStk HappyAbsSyn 
	-> (Alex) HappyAbsSyn)

happyReduce_1,
 happyReduce_2,
 happyReduce_3,
 happyReduce_4,
 happyReduce_5,
 happyReduce_6,
 happyReduce_7,
 happyReduce_8,
 happyReduce_9,
 happyReduce_10,
 happyReduce_11,
 happyReduce_12,
 happyReduce_13,
 happyReduce_14,
 happyReduce_15,
 happyReduce_16,
 happyReduce_17,
 happyReduce_18,
 happyReduce_19,
 happyReduce_20,
 happyReduce_21,
 happyReduce_22,
 happyReduce_23,
 happyReduce_24,
 happyReduce_25,
 happyReduce_26,
 happyReduce_27,
 happyReduce_28,
 happyReduce_29,
 happyReduce_30,
 happyReduce_31,
 happyReduce_32,
 happyReduce_33,
 happyReduce_34,
 happyReduce_35,
 happyReduce_36,
 happyReduce_37,
 happyReduce_38,
 happyReduce_39,
 happyReduce_40,
 happyReduce_41,
 happyReduce_42,
 happyReduce_43,
 happyReduce_44,
 happyReduce_45,
 happyReduce_46,
 happyReduce_47,
 happyReduce_48,
 happyReduce_49,
 happyReduce_50,
 happyReduce_51,
 happyReduce_52,
 happyReduce_53,
 happyReduce_54,
 happyReduce_55,
 happyReduce_56,
 happyReduce_57,
 happyReduce_58,
 happyReduce_59,
 happyReduce_60,
 happyReduce_61,
 happyReduce_62,
 happyReduce_63,
 happyReduce_64,
 happyReduce_65,
 happyReduce_66,
 happyReduce_67,
 happyReduce_68,
 happyReduce_69,
 happyReduce_70,
 happyReduce_71,
 happyReduce_72,
 happyReduce_73,
 happyReduce_74,
 happyReduce_75,
 happyReduce_76,
 happyReduce_77,
 happyReduce_78,
 happyReduce_79,
 happyReduce_80,
 happyReduce_81,
 happyReduce_82,
 happyReduce_83,
 happyReduce_84,
 happyReduce_85,
 happyReduce_86,
 happyReduce_87,
 happyReduce_88,
 happyReduce_89,
 happyReduce_90,
 happyReduce_91,
 happyReduce_92,
 happyReduce_93,
 happyReduce_94,
 happyReduce_95,
 happyReduce_96,
 happyReduce_97,
 happyReduce_98,
 happyReduce_99,
 happyReduce_100,
 happyReduce_101,
 happyReduce_102,
 happyReduce_103,
 happyReduce_104,
 happyReduce_105,
 happyReduce_106,
 happyReduce_107,
 happyReduce_108,
 happyReduce_109,
 happyReduce_110,
 happyReduce_111,
 happyReduce_112,
 happyReduce_113,
 happyReduce_114,
 happyReduce_115,
 happyReduce_116,
 happyReduce_117,
 happyReduce_118,
 happyReduce_119,
 happyReduce_120,
 happyReduce_121,
 happyReduce_122,
 happyReduce_123,
 happyReduce_124,
 happyReduce_125,
 happyReduce_126,
 happyReduce_127,
 happyReduce_128,
 happyReduce_129,
 happyReduce_130,
 happyReduce_131,
 happyReduce_132,
 happyReduce_133,
 happyReduce_134,
 happyReduce_135,
 happyReduce_136,
 happyReduce_137,
 happyReduce_138,
 happyReduce_139,
 happyReduce_140,
 happyReduce_141,
 happyReduce_142,
 happyReduce_143,
 happyReduce_144,
 happyReduce_145,
 happyReduce_146,
 happyReduce_147,
 happyReduce_148,
 happyReduce_149,
 happyReduce_150,
 happyReduce_151,
 happyReduce_152 :: () => ({-HappyReduction (Alex) = -}
	   Prelude.Int 
	-> (Token)
	-> HappyState (Token) (HappyStk HappyAbsSyn -> (Alex) HappyAbsSyn)
	-> [HappyState (Token) (HappyStk HappyAbsSyn -> (Alex) HappyAbsSyn)] 
	-> HappyStk HappyAbsSyn 
	-> (Alex) HappyAbsSyn)

happyExpList :: Happy_Data_Array.Array Prelude.Int Prelude.Int
happyExpList = Happy_Data_Array.listArray (0,585) ([0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,396,276,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,388,276,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1024,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,256,0,0,0,0,0,0,0,0,0,16,0,0,0,0,0,0,4096,0,0,0,0,0,1,0,0,0,0,0,0,64,0,0,0,0,0,0,16384,0,0,0,0,0,0,0,8192,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4096,0,0,0,0,0,0,0,16,0,0,0,0,0,0,0,0,0,0,0,16384,1,0,1,0,0,0,0,0,0,0,0,0,0,0,16384,1,0,1,0,0,0,0,64,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16384,0,2,0,0,0,0,0,0,0,16,0,0,0,0,0,0,0,0,0,0,0,49152,19,202,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,2,0,0,0,0,0,96,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16,0,0,0,0,0,0,256,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,64,0,0,0,0,0,0,0,0,0,4,0,0,0,0,960,32768,256,0,0,0,0,49152,3,128,1,0,0,0,0,0,0,256,0,0,0,0,49152,3,128,1,0,0,0,0,0,0,1024,0,0,0,0,16384,0,0,0,0,0,0,0,256,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8192,0,0,0,0,0,0,4096,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16,0,0,0,0,320,0,256,0,0,0,0,0,0,2048,0,0,0,0,0,8192,0,0,0,0,0,0,0,0,0,1,0,0,0,0,320,0,256,0,0,0,0,16384,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,32,0,0,0,0,64,0,0,0,0,0,0,0,1,0,0,0,0,0,0,256,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,16,0,0,0,0,0,0,0,0,0,0,0,0,320,0,256,0,0,0,0,0,1,0,0,0,0,0,0,320,0,256,0,0,0,0,0,0,32768,0,0,0,0,0,256,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8192,0,0,0,0,0,0,4096,0,0,0,0,0,64,13312,1,0,0,0,0,0,64,0,2,0,0,0,0,64,0,0,0,0,0,0,0,64,0,0,0,0,0,0,0,0,1024,0,0,0,0,0,64,4096,0,0,0,0,0,0,0,0,0,0,0,0,49152,52754,1,4,0,0,0,0,8192,0,8,0,0,0,0,0,0,0,0,0,0,0,0,960,32768,256,0,0,0,0,0,0,0,0,0,0,0,0,960,32768,256,0,0,0,0,49152,3,128,1,0,0,0,0,64,0,0,0,0,0,0,49152,19,202,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,256,0,0,0,0,0,64,0,0,0,0,0,0,16384,0,16,0,0,0,0,0,0,0,32,0,0,0,0,0,0,512,0,0,0,0,0,0,0,0,0,0,0,0,960,32768,256,0,0,0,0,16384,1,0,1,0,0,0,0,0,0,272,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2048,0,0,0,0,0,0,512,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1024,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,64,0,0,0,0,0,0,49152,2,0,0,0,0,0,0,0,0,1024,0,0,0,0,49152,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,49152,3,128,1,0,0,0,0,0,0,16384,0,0,0,0,0,0,0,2,0,0,0,0,0,0,16,0,0,0,0,0,0,2048,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,64,13312,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,1,0,0,0,0,64,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4096,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16,0,0,0,0,0,0,8192,0,0,0,0,16384,1,0,1,0,0,0,0,0,0,32,0,0,0,0,0,0,0,16,0,0,0,0,0,0,0,0,0,0,0,0,0,0,64,0,0,0,0,0,0,4096,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,8192,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1024,0,0,0,0,16384,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,16384,0,0,0,0,0,0,0,320,0,256,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16384,1,0,1,0,0,0,0,64,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,2048,0,0,0,0,0,0,0,64,0,0,0,0,960,0,320,0,0,0,0,0,0,0,0,0,0,0,0,0,0,256,0,0,0,0,0,4096,0,0,0,0,0,0,704,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,16,0,0,0,0,0,0,1024,0,0,0,0,0,704,0,0,0,0,0,0,49152,52754,1,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16384,0,0,0,0,0,0,0,704,0,0,0,0,0,0,0,32,0,0,0,0,0,0,16384,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,49152,3,128,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4096,0,0,0,0,0,0,0,512,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,49152,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,32,0,0,0,0,0,0,4096,0,0,0,0,0,0,640,0,0,0,0,0,0,0,0,32768,0,0,0,0,0,0,0,16,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4096,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,49152,3,16384,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,32,0,0,0,0,0,0,0,0,512,0,0,0,0,0,0,0,0,0,0,0,0,0,4096,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,320,0,256,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2048,0,0,0,0,0,0,16,0,0,0,0,0,0,0,2048,0,0,0,0,0,0,512,0,0,0,0,0,0,0,1024,0,0,0,0,0,0,512,0,0,0,0,0,0,0,512,0,0,0,0,0,0,0,0,0,0,0,0,960,0,320,0,0,0,0,49152,3,16384,1,0,0,0,0,5056,51712,256,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1024,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,704,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4096,0,0,0,0,0,0,0,8192,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4096,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,960,0,320,0,0,0,0,0,0,0,0,0
	])

{-# NOINLINE happyExpListPerState #-}
happyExpListPerState st =
    token_strs_expected
  where token_strs = ["error","%dummy","%start_parser","CompilationUnit","ImportList","Import","TopDeclList","TopDecl","Contract","DeclList","Decl","TypeSynonym","FieldDef","DataDef","Constrs","Constr","ClassDef","ClassBody","OptParam","VarCommaList","ContextOpt","Context","ConstraintList","Constraint","Signatures","Signature","ConOpt","ParamList","Param","InstDef","OptTypeParam","TypeCommaList","Functions","InstBody","Function","OptRetTy","Constructor","Body","StmtList","Stmt","MatchArgList","InitOpt","Expr","ConArgs","FunArgs","ExprCommaList","Equations","Equation","PatCommaList","Pattern","PatternList","PatList","Literal","Type","LamType","Var","Con","QualName","Name","AsmBlock","YulBlock","YulStmts","YulStmt","YulFor","YulSwitch","YulCases","YulCase","YulDefault","YulIf","YulVarDecl","YulOptAss","YulAssignment","IdentifierList","YulExp","YulFunArgs","YulExpCommaList","YulLiteral","OptSemi","identifier","number","tycon","stringlit","'contract'","'import'","'let'","'='","'.'","'class'","'instance'","'if'","'for'","'switch'","'case'","'default'","'leave'","'continue'","'break'","'assembly'","'data'","'match'","'function'","'constructor'","'return'","'lam'","'type'","';'","':='","':'","','","'->'","'_'","'=>'","'('","')'","'{'","'}'","'['","']'","'|'","%eof"]
        bit_start = st Prelude.* 120
        bit_end = (st Prelude.+ 1) Prelude.* 120
        read_bit = readArrayBit happyExpList
        bits = Prelude.map read_bit [bit_start..bit_end Prelude.- 1]
        bits_indexed = Prelude.zip bits [0..119]
        token_strs_expected = Prelude.concatMap f bits_indexed
        f (Prelude.False, _) = []
        f (Prelude.True, nr) = [token_strs Prelude.!! nr]

action_0 (4) = happyGoto action_3
action_0 (5) = happyGoto action_2
action_0 _ = happyReduce_3

action_1 (5) = happyGoto action_2
action_1 _ = happyFail (happyExpListPerState 1)

action_2 (83) = happyShift action_14
action_2 (84) = happyShift action_15
action_2 (88) = happyShift action_16
action_2 (89) = happyShift action_17
action_2 (99) = happyShift action_18
action_2 (101) = happyShift action_19
action_2 (105) = happyShift action_20
action_2 (6) = happyGoto action_4
action_2 (7) = happyGoto action_5
action_2 (8) = happyGoto action_6
action_2 (9) = happyGoto action_7
action_2 (12) = happyGoto action_8
action_2 (14) = happyGoto action_9
action_2 (17) = happyGoto action_10
action_2 (26) = happyGoto action_11
action_2 (30) = happyGoto action_12
action_2 (35) = happyGoto action_13
action_2 _ = happyReduce_6

action_3 (120) = happyAccept
action_3 _ = happyFail (happyExpListPerState 3)

action_4 _ = happyReduce_2

action_5 _ = happyReduce_1

action_6 (83) = happyShift action_14
action_6 (88) = happyShift action_16
action_6 (89) = happyShift action_17
action_6 (99) = happyShift action_18
action_6 (101) = happyShift action_19
action_6 (105) = happyShift action_20
action_6 (7) = happyGoto action_35
action_6 (8) = happyGoto action_6
action_6 (9) = happyGoto action_7
action_6 (12) = happyGoto action_8
action_6 (14) = happyGoto action_9
action_6 (17) = happyGoto action_10
action_6 (26) = happyGoto action_11
action_6 (30) = happyGoto action_12
action_6 (35) = happyGoto action_13
action_6 _ = happyReduce_6

action_7 _ = happyReduce_7

action_8 _ = happyReduce_12

action_9 _ = happyReduce_11

action_10 _ = happyReduce_9

action_11 (115) = happyShift action_34
action_11 (38) = happyGoto action_33
action_11 _ = happyFail (happyExpListPerState 11)

action_12 _ = happyReduce_10

action_13 _ = happyReduce_8

action_14 (81) = happyShift action_25
action_14 (57) = happyGoto action_32
action_14 _ = happyFail (happyExpListPerState 14)

action_15 (81) = happyShift action_25
action_15 (57) = happyGoto action_30
action_15 (58) = happyGoto action_31
action_15 _ = happyFail (happyExpListPerState 15)

action_16 (117) = happyShift action_28
action_16 (21) = happyGoto action_29
action_16 (22) = happyGoto action_27
action_16 _ = happyReduce_33

action_17 (117) = happyShift action_28
action_17 (21) = happyGoto action_26
action_17 (22) = happyGoto action_27
action_17 _ = happyReduce_33

action_18 (81) = happyShift action_25
action_18 (57) = happyGoto action_24
action_18 _ = happyFail (happyExpListPerState 18)

action_19 (79) = happyShift action_22
action_19 (59) = happyGoto action_23
action_19 _ = happyFail (happyExpListPerState 19)

action_20 (79) = happyShift action_22
action_20 (59) = happyGoto action_21
action_20 _ = happyFail (happyExpListPerState 20)

action_21 (86) = happyShift action_68
action_21 _ = happyFail (happyExpListPerState 21)

action_22 _ = happyReduce_113

action_23 (117) = happyShift action_67
action_23 (27) = happyGoto action_66
action_23 _ = happyReduce_42

action_24 (117) = happyShift action_52
action_24 (19) = happyGoto action_65
action_24 _ = happyReduce_30

action_25 _ = happyReduce_110

action_26 (79) = happyShift action_22
action_26 (81) = happyShift action_25
action_26 (113) = happyShift action_63
action_26 (54) = happyGoto action_64
action_26 (55) = happyGoto action_60
action_26 (56) = happyGoto action_61
action_26 (57) = happyGoto action_62
action_26 (59) = happyGoto action_56
action_26 _ = happyFail (happyExpListPerState 26)

action_27 _ = happyReduce_34

action_28 (79) = happyShift action_22
action_28 (81) = happyShift action_25
action_28 (113) = happyShift action_63
action_28 (23) = happyGoto action_57
action_28 (24) = happyGoto action_58
action_28 (54) = happyGoto action_59
action_28 (55) = happyGoto action_60
action_28 (56) = happyGoto action_61
action_28 (57) = happyGoto action_62
action_28 (59) = happyGoto action_56
action_28 _ = happyFail (happyExpListPerState 28)

action_29 (79) = happyShift action_22
action_29 (56) = happyGoto action_55
action_29 (59) = happyGoto action_56
action_29 _ = happyFail (happyExpListPerState 29)

action_30 _ = happyReduce_111

action_31 (87) = happyShift action_53
action_31 (106) = happyShift action_54
action_31 _ = happyFail (happyExpListPerState 31)

action_32 (117) = happyShift action_52
action_32 (19) = happyGoto action_51
action_32 _ = happyReduce_30

action_33 _ = happyReduce_57

action_34 (79) = happyShift action_22
action_34 (80) = happyShift action_43
action_34 (81) = happyShift action_25
action_34 (82) = happyShift action_44
action_34 (85) = happyShift action_45
action_34 (98) = happyShift action_46
action_34 (100) = happyShift action_47
action_34 (103) = happyShift action_48
action_34 (104) = happyShift action_49
action_34 (113) = happyShift action_50
action_34 (39) = happyGoto action_36
action_34 (40) = happyGoto action_37
action_34 (43) = happyGoto action_38
action_34 (53) = happyGoto action_39
action_34 (57) = happyGoto action_40
action_34 (59) = happyGoto action_41
action_34 (60) = happyGoto action_42
action_34 _ = happyReduce_63

action_35 _ = happyReduce_5

action_36 (116) = happyShift action_101
action_36 _ = happyFail (happyExpListPerState 36)

action_37 (106) = happyShift action_100
action_37 _ = happyFail (happyExpListPerState 37)

action_38 (86) = happyShift action_98
action_38 (87) = happyShift action_99
action_38 _ = happyReduce_67

action_39 _ = happyReduce_77

action_40 (117) = happyShift action_97
action_40 (44) = happyGoto action_96
action_40 _ = happyReduce_84

action_41 (113) = happyShift action_95
action_41 (45) = happyGoto action_94
action_41 _ = happyReduce_75

action_42 _ = happyReduce_70

action_43 _ = happyReduce_103

action_44 _ = happyReduce_104

action_45 (79) = happyShift action_22
action_45 (59) = happyGoto action_93
action_45 _ = happyFail (happyExpListPerState 45)

action_46 (115) = happyShift action_92
action_46 (61) = happyGoto action_91
action_46 _ = happyFail (happyExpListPerState 46)

action_47 (79) = happyShift action_22
action_47 (80) = happyShift action_43
action_47 (81) = happyShift action_25
action_47 (82) = happyShift action_44
action_47 (104) = happyShift action_49
action_47 (113) = happyShift action_50
action_47 (41) = happyGoto action_89
action_47 (43) = happyGoto action_90
action_47 (53) = happyGoto action_39
action_47 (57) = happyGoto action_40
action_47 (59) = happyGoto action_41
action_47 _ = happyFail (happyExpListPerState 47)

action_48 (79) = happyShift action_22
action_48 (80) = happyShift action_43
action_48 (81) = happyShift action_25
action_48 (82) = happyShift action_44
action_48 (104) = happyShift action_49
action_48 (113) = happyShift action_50
action_48 (43) = happyGoto action_88
action_48 (53) = happyGoto action_39
action_48 (57) = happyGoto action_40
action_48 (59) = happyGoto action_41
action_48 _ = happyFail (happyExpListPerState 48)

action_49 (113) = happyShift action_87
action_49 _ = happyFail (happyExpListPerState 49)

action_50 (79) = happyShift action_22
action_50 (80) = happyShift action_43
action_50 (81) = happyShift action_25
action_50 (82) = happyShift action_44
action_50 (104) = happyShift action_49
action_50 (113) = happyShift action_50
action_50 (43) = happyGoto action_86
action_50 (53) = happyGoto action_39
action_50 (57) = happyGoto action_40
action_50 (59) = happyGoto action_41
action_50 _ = happyFail (happyExpListPerState 50)

action_51 (115) = happyShift action_85
action_51 _ = happyFail (happyExpListPerState 51)

action_52 (79) = happyShift action_22
action_52 (20) = happyGoto action_83
action_52 (56) = happyGoto action_84
action_52 (59) = happyGoto action_56
action_52 _ = happyFail (happyExpListPerState 52)

action_53 (81) = happyShift action_25
action_53 (57) = happyGoto action_82
action_53 _ = happyFail (happyExpListPerState 53)

action_54 _ = happyReduce_4

action_55 (108) = happyShift action_81
action_55 _ = happyFail (happyExpListPerState 55)

action_56 _ = happyReduce_109

action_57 (118) = happyShift action_80
action_57 _ = happyFail (happyExpListPerState 57)

action_58 (109) = happyShift action_79
action_58 _ = happyReduce_37

action_59 (108) = happyShift action_78
action_59 _ = happyFail (happyExpListPerState 59)

action_60 _ = happyReduce_107

action_61 _ = happyReduce_106

action_62 (117) = happyShift action_77
action_62 (31) = happyGoto action_76
action_62 _ = happyReduce_51

action_63 (79) = happyShift action_22
action_63 (81) = happyShift action_25
action_63 (113) = happyShift action_63
action_63 (32) = happyGoto action_74
action_63 (54) = happyGoto action_75
action_63 (55) = happyGoto action_60
action_63 (56) = happyGoto action_61
action_63 (57) = happyGoto action_62
action_63 (59) = happyGoto action_56
action_63 _ = happyFail (happyExpListPerState 63)

action_64 (108) = happyShift action_73
action_64 _ = happyFail (happyExpListPerState 64)

action_65 (86) = happyShift action_72
action_65 _ = happyFail (happyExpListPerState 65)

action_66 (113) = happyShift action_71
action_66 _ = happyFail (happyExpListPerState 66)

action_67 (79) = happyShift action_22
action_67 (81) = happyShift action_25
action_67 (113) = happyShift action_63
action_67 (23) = happyGoto action_70
action_67 (24) = happyGoto action_58
action_67 (54) = happyGoto action_59
action_67 (55) = happyGoto action_60
action_67 (56) = happyGoto action_61
action_67 (57) = happyGoto action_62
action_67 (59) = happyGoto action_56
action_67 _ = happyFail (happyExpListPerState 67)

action_68 (79) = happyShift action_22
action_68 (81) = happyShift action_25
action_68 (113) = happyShift action_63
action_68 (54) = happyGoto action_69
action_68 (55) = happyGoto action_60
action_68 (56) = happyGoto action_61
action_68 (57) = happyGoto action_62
action_68 (59) = happyGoto action_56
action_68 _ = happyFail (happyExpListPerState 68)

action_69 _ = happyReduce_21

action_70 (118) = happyShift action_161
action_70 _ = happyFail (happyExpListPerState 70)

action_71 (79) = happyShift action_22
action_71 (28) = happyGoto action_160
action_71 (29) = happyGoto action_135
action_71 (59) = happyGoto action_136
action_71 _ = happyReduce_46

action_72 (81) = happyShift action_25
action_72 (15) = happyGoto action_157
action_72 (16) = happyGoto action_158
action_72 (57) = happyGoto action_159
action_72 _ = happyFail (happyExpListPerState 72)

action_73 (81) = happyShift action_25
action_73 (57) = happyGoto action_156
action_73 _ = happyFail (happyExpListPerState 73)

action_74 (114) = happyShift action_155
action_74 _ = happyFail (happyExpListPerState 74)

action_75 (109) = happyShift action_154
action_75 _ = happyReduce_53

action_76 _ = happyReduce_105

action_77 (79) = happyShift action_22
action_77 (81) = happyShift action_25
action_77 (113) = happyShift action_63
action_77 (32) = happyGoto action_153
action_77 (54) = happyGoto action_75
action_77 (55) = happyGoto action_60
action_77 (56) = happyGoto action_61
action_77 (57) = happyGoto action_62
action_77 (59) = happyGoto action_56
action_77 _ = happyFail (happyExpListPerState 77)

action_78 (81) = happyShift action_25
action_78 (57) = happyGoto action_152
action_78 _ = happyFail (happyExpListPerState 78)

action_79 (79) = happyShift action_22
action_79 (81) = happyShift action_25
action_79 (113) = happyShift action_63
action_79 (23) = happyGoto action_151
action_79 (24) = happyGoto action_58
action_79 (54) = happyGoto action_59
action_79 (55) = happyGoto action_60
action_79 (56) = happyGoto action_61
action_79 (57) = happyGoto action_62
action_79 (59) = happyGoto action_56
action_79 _ = happyFail (happyExpListPerState 79)

action_80 (112) = happyShift action_150
action_80 _ = happyFail (happyExpListPerState 80)

action_81 (81) = happyShift action_25
action_81 (57) = happyGoto action_149
action_81 _ = happyFail (happyExpListPerState 81)

action_82 _ = happyReduce_112

action_83 (118) = happyShift action_148
action_83 _ = happyFail (happyExpListPerState 83)

action_84 (109) = happyShift action_147
action_84 _ = happyReduce_32

action_85 (79) = happyShift action_22
action_85 (99) = happyShift action_18
action_85 (101) = happyShift action_19
action_85 (102) = happyShift action_146
action_85 (105) = happyShift action_20
action_85 (10) = happyGoto action_138
action_85 (11) = happyGoto action_139
action_85 (12) = happyGoto action_140
action_85 (13) = happyGoto action_141
action_85 (14) = happyGoto action_142
action_85 (26) = happyGoto action_11
action_85 (35) = happyGoto action_143
action_85 (37) = happyGoto action_144
action_85 (59) = happyGoto action_145
action_85 _ = happyReduce_15

action_86 (87) = happyShift action_99
action_86 (114) = happyShift action_137
action_86 _ = happyFail (happyExpListPerState 86)

action_87 (79) = happyShift action_22
action_87 (28) = happyGoto action_134
action_87 (29) = happyGoto action_135
action_87 (59) = happyGoto action_136
action_87 _ = happyReduce_46

action_88 (87) = happyShift action_99
action_88 _ = happyReduce_68

action_89 (115) = happyShift action_133
action_89 _ = happyFail (happyExpListPerState 89)

action_90 (87) = happyShift action_99
action_90 (109) = happyShift action_132
action_90 _ = happyReduce_71

action_91 _ = happyReduce_114

action_92 (79) = happyShift action_22
action_92 (80) = happyShift action_123
action_92 (82) = happyShift action_124
action_92 (85) = happyShift action_125
action_92 (90) = happyShift action_126
action_92 (91) = happyShift action_127
action_92 (92) = happyShift action_128
action_92 (95) = happyShift action_129
action_92 (96) = happyShift action_130
action_92 (97) = happyShift action_131
action_92 (115) = happyShift action_92
action_92 (59) = happyGoto action_111
action_92 (61) = happyGoto action_112
action_92 (62) = happyGoto action_113
action_92 (63) = happyGoto action_114
action_92 (64) = happyGoto action_115
action_92 (65) = happyGoto action_116
action_92 (69) = happyGoto action_117
action_92 (70) = happyGoto action_118
action_92 (72) = happyGoto action_119
action_92 (73) = happyGoto action_120
action_92 (74) = happyGoto action_121
action_92 (77) = happyGoto action_122
action_92 _ = happyReduce_117

action_93 (86) = happyShift action_109
action_93 (108) = happyShift action_110
action_93 (42) = happyGoto action_108
action_93 _ = happyReduce_73

action_94 _ = happyReduce_81

action_95 (79) = happyShift action_22
action_95 (80) = happyShift action_43
action_95 (81) = happyShift action_25
action_95 (82) = happyShift action_44
action_95 (104) = happyShift action_49
action_95 (113) = happyShift action_50
action_95 (43) = happyGoto action_105
action_95 (46) = happyGoto action_107
action_95 (53) = happyGoto action_39
action_95 (57) = happyGoto action_40
action_95 (59) = happyGoto action_41
action_95 _ = happyReduce_87

action_96 _ = happyReduce_76

action_97 (79) = happyShift action_22
action_97 (80) = happyShift action_43
action_97 (81) = happyShift action_25
action_97 (82) = happyShift action_44
action_97 (104) = happyShift action_49
action_97 (113) = happyShift action_50
action_97 (43) = happyGoto action_105
action_97 (46) = happyGoto action_106
action_97 (53) = happyGoto action_39
action_97 (57) = happyGoto action_40
action_97 (59) = happyGoto action_41
action_97 _ = happyReduce_87

action_98 (79) = happyShift action_22
action_98 (80) = happyShift action_43
action_98 (81) = happyShift action_25
action_98 (82) = happyShift action_44
action_98 (104) = happyShift action_49
action_98 (113) = happyShift action_50
action_98 (43) = happyGoto action_104
action_98 (53) = happyGoto action_39
action_98 (57) = happyGoto action_40
action_98 (59) = happyGoto action_41
action_98 _ = happyFail (happyExpListPerState 98)

action_99 (79) = happyShift action_22
action_99 (59) = happyGoto action_103
action_99 _ = happyFail (happyExpListPerState 99)

action_100 (79) = happyShift action_22
action_100 (80) = happyShift action_43
action_100 (81) = happyShift action_25
action_100 (82) = happyShift action_44
action_100 (85) = happyShift action_45
action_100 (98) = happyShift action_46
action_100 (100) = happyShift action_47
action_100 (103) = happyShift action_48
action_100 (104) = happyShift action_49
action_100 (113) = happyShift action_50
action_100 (39) = happyGoto action_102
action_100 (40) = happyGoto action_37
action_100 (43) = happyGoto action_38
action_100 (53) = happyGoto action_39
action_100 (57) = happyGoto action_40
action_100 (59) = happyGoto action_41
action_100 (60) = happyGoto action_42
action_100 _ = happyReduce_63

action_101 _ = happyReduce_61

action_102 _ = happyReduce_62

action_103 (113) = happyShift action_95
action_103 (45) = happyGoto action_201
action_103 _ = happyReduce_79

action_104 (87) = happyShift action_99
action_104 _ = happyReduce_64

action_105 (87) = happyShift action_99
action_105 (109) = happyShift action_200
action_105 _ = happyReduce_86

action_106 (118) = happyShift action_199
action_106 _ = happyFail (happyExpListPerState 106)

action_107 (114) = happyShift action_198
action_107 _ = happyFail (happyExpListPerState 107)

action_108 _ = happyReduce_66

action_109 (79) = happyShift action_22
action_109 (80) = happyShift action_43
action_109 (81) = happyShift action_25
action_109 (82) = happyShift action_44
action_109 (104) = happyShift action_49
action_109 (113) = happyShift action_50
action_109 (43) = happyGoto action_197
action_109 (53) = happyGoto action_39
action_109 (57) = happyGoto action_40
action_109 (59) = happyGoto action_41
action_109 _ = happyFail (happyExpListPerState 109)

action_110 (79) = happyShift action_22
action_110 (81) = happyShift action_25
action_110 (113) = happyShift action_63
action_110 (54) = happyGoto action_196
action_110 (55) = happyGoto action_60
action_110 (56) = happyGoto action_61
action_110 (57) = happyGoto action_62
action_110 (59) = happyGoto action_56
action_110 _ = happyFail (happyExpListPerState 110)

action_111 (107) = happyReduce_140
action_111 (109) = happyShift action_194
action_111 (113) = happyShift action_195
action_111 (75) = happyGoto action_193
action_111 _ = happyReduce_143

action_112 _ = happyReduce_119

action_113 (116) = happyShift action_192
action_113 _ = happyFail (happyExpListPerState 113)

action_114 (106) = happyShift action_191
action_114 (78) = happyGoto action_190
action_114 _ = happyReduce_152

action_115 _ = happyReduce_124

action_116 _ = happyReduce_123

action_117 _ = happyReduce_122

action_118 _ = happyReduce_120

action_119 _ = happyReduce_118

action_120 (107) = happyShift action_189
action_120 _ = happyFail (happyExpListPerState 120)

action_121 _ = happyReduce_121

action_122 _ = happyReduce_142

action_123 _ = happyReduce_149

action_124 _ = happyReduce_150

action_125 (79) = happyShift action_22
action_125 (59) = happyGoto action_187
action_125 (73) = happyGoto action_188
action_125 _ = happyFail (happyExpListPerState 125)

action_126 (79) = happyShift action_22
action_126 (80) = happyShift action_123
action_126 (82) = happyShift action_124
action_126 (59) = happyGoto action_183
action_126 (74) = happyGoto action_186
action_126 (77) = happyGoto action_122
action_126 _ = happyFail (happyExpListPerState 126)

action_127 (115) = happyShift action_92
action_127 (61) = happyGoto action_185
action_127 _ = happyFail (happyExpListPerState 127)

action_128 (79) = happyShift action_22
action_128 (80) = happyShift action_123
action_128 (82) = happyShift action_124
action_128 (59) = happyGoto action_183
action_128 (74) = happyGoto action_184
action_128 (77) = happyGoto action_122
action_128 _ = happyFail (happyExpListPerState 128)

action_129 _ = happyReduce_127

action_130 _ = happyReduce_125

action_131 _ = happyReduce_126

action_132 (79) = happyShift action_22
action_132 (80) = happyShift action_43
action_132 (81) = happyShift action_25
action_132 (82) = happyShift action_44
action_132 (104) = happyShift action_49
action_132 (113) = happyShift action_50
action_132 (41) = happyGoto action_182
action_132 (43) = happyGoto action_90
action_132 (53) = happyGoto action_39
action_132 (57) = happyGoto action_40
action_132 (59) = happyGoto action_41
action_132 _ = happyFail (happyExpListPerState 132)

action_133 (119) = happyShift action_181
action_133 (47) = happyGoto action_179
action_133 (48) = happyGoto action_180
action_133 _ = happyReduce_90

action_134 (114) = happyShift action_178
action_134 _ = happyFail (happyExpListPerState 134)

action_135 (109) = happyShift action_177
action_135 _ = happyReduce_44

action_136 (108) = happyShift action_176
action_136 _ = happyReduce_48

action_137 _ = happyReduce_78

action_138 (116) = happyShift action_175
action_138 _ = happyFail (happyExpListPerState 138)

action_139 (79) = happyShift action_22
action_139 (99) = happyShift action_18
action_139 (101) = happyShift action_19
action_139 (102) = happyShift action_146
action_139 (105) = happyShift action_20
action_139 (10) = happyGoto action_174
action_139 (11) = happyGoto action_139
action_139 (12) = happyGoto action_140
action_139 (13) = happyGoto action_141
action_139 (14) = happyGoto action_142
action_139 (26) = happyGoto action_11
action_139 (35) = happyGoto action_143
action_139 (37) = happyGoto action_144
action_139 (59) = happyGoto action_145
action_139 _ = happyReduce_15

action_140 _ = happyReduce_20

action_141 _ = happyReduce_16

action_142 _ = happyReduce_17

action_143 _ = happyReduce_18

action_144 _ = happyReduce_19

action_145 (108) = happyShift action_173
action_145 _ = happyFail (happyExpListPerState 145)

action_146 (113) = happyShift action_172
action_146 _ = happyFail (happyExpListPerState 146)

action_147 (79) = happyShift action_22
action_147 (20) = happyGoto action_171
action_147 (56) = happyGoto action_84
action_147 (59) = happyGoto action_56
action_147 _ = happyFail (happyExpListPerState 147)

action_148 _ = happyReduce_29

action_149 (117) = happyShift action_52
action_149 (19) = happyGoto action_170
action_149 _ = happyReduce_30

action_150 _ = happyReduce_35

action_151 _ = happyReduce_36

action_152 (117) = happyShift action_77
action_152 (31) = happyGoto action_169
action_152 _ = happyReduce_51

action_153 (118) = happyShift action_168
action_153 _ = happyFail (happyExpListPerState 153)

action_154 (79) = happyShift action_22
action_154 (81) = happyShift action_25
action_154 (113) = happyShift action_63
action_154 (32) = happyGoto action_167
action_154 (54) = happyGoto action_75
action_154 (55) = happyGoto action_60
action_154 (56) = happyGoto action_61
action_154 (57) = happyGoto action_62
action_154 (59) = happyGoto action_56
action_154 _ = happyFail (happyExpListPerState 154)

action_155 (110) = happyShift action_166
action_155 _ = happyFail (happyExpListPerState 155)

action_156 (117) = happyShift action_77
action_156 (31) = happyGoto action_165
action_156 _ = happyReduce_51

action_157 _ = happyReduce_23

action_158 (119) = happyShift action_164
action_158 _ = happyReduce_25

action_159 (117) = happyShift action_77
action_159 (31) = happyGoto action_163
action_159 _ = happyReduce_51

action_160 (114) = happyShift action_162
action_160 _ = happyFail (happyExpListPerState 160)

action_161 _ = happyReduce_43

action_162 (110) = happyShift action_237
action_162 (36) = happyGoto action_236
action_162 _ = happyReduce_59

action_163 _ = happyReduce_26

action_164 (81) = happyShift action_25
action_164 (15) = happyGoto action_235
action_164 (16) = happyGoto action_158
action_164 (57) = happyGoto action_159
action_164 _ = happyFail (happyExpListPerState 164)

action_165 (115) = happyShift action_234
action_165 (34) = happyGoto action_233
action_165 _ = happyFail (happyExpListPerState 165)

action_166 (79) = happyShift action_22
action_166 (81) = happyShift action_25
action_166 (113) = happyShift action_63
action_166 (54) = happyGoto action_232
action_166 (55) = happyGoto action_60
action_166 (56) = happyGoto action_61
action_166 (57) = happyGoto action_62
action_166 (59) = happyGoto action_56
action_166 _ = happyFail (happyExpListPerState 166)

action_167 _ = happyReduce_52

action_168 _ = happyReduce_50

action_169 _ = happyReduce_38

action_170 (115) = happyShift action_231
action_170 (18) = happyGoto action_230
action_170 _ = happyFail (happyExpListPerState 170)

action_171 _ = happyReduce_31

action_172 (79) = happyShift action_22
action_172 (28) = happyGoto action_229
action_172 (29) = happyGoto action_135
action_172 (59) = happyGoto action_136
action_172 _ = happyReduce_46

action_173 (79) = happyShift action_22
action_173 (81) = happyShift action_25
action_173 (113) = happyShift action_63
action_173 (54) = happyGoto action_228
action_173 (55) = happyGoto action_60
action_173 (56) = happyGoto action_61
action_173 (57) = happyGoto action_62
action_173 (59) = happyGoto action_56
action_173 _ = happyFail (happyExpListPerState 173)

action_174 _ = happyReduce_14

action_175 _ = happyReduce_13

action_176 (79) = happyShift action_22
action_176 (81) = happyShift action_25
action_176 (113) = happyShift action_63
action_176 (54) = happyGoto action_227
action_176 (55) = happyGoto action_60
action_176 (56) = happyGoto action_61
action_176 (57) = happyGoto action_62
action_176 (59) = happyGoto action_56
action_176 _ = happyFail (happyExpListPerState 176)

action_177 (79) = happyShift action_22
action_177 (28) = happyGoto action_226
action_177 (29) = happyGoto action_135
action_177 (59) = happyGoto action_136
action_177 _ = happyReduce_46

action_178 (115) = happyShift action_34
action_178 (38) = happyGoto action_225
action_178 _ = happyFail (happyExpListPerState 178)

action_179 (116) = happyShift action_224
action_179 _ = happyFail (happyExpListPerState 179)

action_180 (119) = happyShift action_181
action_180 (47) = happyGoto action_223
action_180 (48) = happyGoto action_180
action_180 _ = happyReduce_90

action_181 (79) = happyShift action_22
action_181 (80) = happyShift action_43
action_181 (81) = happyShift action_25
action_181 (82) = happyShift action_44
action_181 (111) = happyShift action_221
action_181 (113) = happyShift action_222
action_181 (49) = happyGoto action_216
action_181 (50) = happyGoto action_217
action_181 (53) = happyGoto action_218
action_181 (57) = happyGoto action_219
action_181 (59) = happyGoto action_220
action_181 _ = happyFail (happyExpListPerState 181)

action_182 _ = happyReduce_72

action_183 (113) = happyShift action_195
action_183 (75) = happyGoto action_193
action_183 _ = happyReduce_143

action_184 (93) = happyShift action_215
action_184 (66) = happyGoto action_213
action_184 (67) = happyGoto action_214
action_184 _ = happyReduce_131

action_185 (79) = happyShift action_22
action_185 (80) = happyShift action_123
action_185 (82) = happyShift action_124
action_185 (59) = happyGoto action_183
action_185 (74) = happyGoto action_212
action_185 (77) = happyGoto action_122
action_185 _ = happyFail (happyExpListPerState 185)

action_186 (115) = happyShift action_92
action_186 (61) = happyGoto action_211
action_186 _ = happyFail (happyExpListPerState 186)

action_187 (109) = happyShift action_194
action_187 _ = happyReduce_140

action_188 (107) = happyShift action_210
action_188 (71) = happyGoto action_209
action_188 _ = happyReduce_138

action_189 (79) = happyShift action_22
action_189 (80) = happyShift action_123
action_189 (82) = happyShift action_124
action_189 (59) = happyGoto action_183
action_189 (74) = happyGoto action_208
action_189 (77) = happyGoto action_122
action_189 _ = happyFail (happyExpListPerState 189)

action_190 (79) = happyShift action_22
action_190 (80) = happyShift action_123
action_190 (82) = happyShift action_124
action_190 (85) = happyShift action_125
action_190 (90) = happyShift action_126
action_190 (91) = happyShift action_127
action_190 (92) = happyShift action_128
action_190 (95) = happyShift action_129
action_190 (96) = happyShift action_130
action_190 (97) = happyShift action_131
action_190 (115) = happyShift action_92
action_190 (59) = happyGoto action_111
action_190 (61) = happyGoto action_112
action_190 (62) = happyGoto action_207
action_190 (63) = happyGoto action_114
action_190 (64) = happyGoto action_115
action_190 (65) = happyGoto action_116
action_190 (69) = happyGoto action_117
action_190 (70) = happyGoto action_118
action_190 (72) = happyGoto action_119
action_190 (73) = happyGoto action_120
action_190 (74) = happyGoto action_121
action_190 (77) = happyGoto action_122
action_190 _ = happyReduce_117

action_191 _ = happyReduce_151

action_192 _ = happyReduce_115

action_193 _ = happyReduce_144

action_194 (79) = happyShift action_22
action_194 (59) = happyGoto action_187
action_194 (73) = happyGoto action_206
action_194 _ = happyFail (happyExpListPerState 194)

action_195 (79) = happyShift action_22
action_195 (80) = happyShift action_123
action_195 (82) = happyShift action_124
action_195 (59) = happyGoto action_183
action_195 (74) = happyGoto action_204
action_195 (76) = happyGoto action_205
action_195 (77) = happyGoto action_122
action_195 _ = happyReduce_147

action_196 (86) = happyShift action_109
action_196 (42) = happyGoto action_203
action_196 _ = happyReduce_73

action_197 (87) = happyShift action_99
action_197 _ = happyReduce_74

action_198 _ = happyReduce_85

action_199 _ = happyReduce_83

action_200 (79) = happyShift action_22
action_200 (80) = happyShift action_43
action_200 (81) = happyShift action_25
action_200 (82) = happyShift action_44
action_200 (104) = happyShift action_49
action_200 (113) = happyShift action_50
action_200 (43) = happyGoto action_105
action_200 (46) = happyGoto action_202
action_200 (53) = happyGoto action_39
action_200 (57) = happyGoto action_40
action_200 (59) = happyGoto action_41
action_200 _ = happyReduce_87

action_201 _ = happyReduce_80

action_202 _ = happyReduce_88

action_203 _ = happyReduce_65

action_204 (109) = happyShift action_257
action_204 _ = happyReduce_146

action_205 (114) = happyShift action_256
action_205 _ = happyFail (happyExpListPerState 205)

action_206 _ = happyReduce_141

action_207 _ = happyReduce_116

action_208 _ = happyReduce_139

action_209 _ = happyReduce_136

action_210 (79) = happyShift action_22
action_210 (80) = happyShift action_123
action_210 (82) = happyShift action_124
action_210 (59) = happyGoto action_183
action_210 (74) = happyGoto action_255
action_210 (77) = happyGoto action_122
action_210 _ = happyFail (happyExpListPerState 210)

action_211 _ = happyReduce_135

action_212 (115) = happyShift action_92
action_212 (61) = happyGoto action_254
action_212 _ = happyFail (happyExpListPerState 212)

action_213 (94) = happyShift action_253
action_213 (68) = happyGoto action_252
action_213 _ = happyReduce_134

action_214 (93) = happyShift action_215
action_214 (66) = happyGoto action_251
action_214 (67) = happyGoto action_214
action_214 _ = happyReduce_131

action_215 (80) = happyShift action_123
action_215 (82) = happyShift action_124
action_215 (77) = happyGoto action_250
action_215 _ = happyFail (happyExpListPerState 215)

action_216 (112) = happyShift action_249
action_216 _ = happyFail (happyExpListPerState 216)

action_217 (109) = happyShift action_248
action_217 _ = happyReduce_92

action_218 _ = happyReduce_97

action_219 (117) = happyShift action_247
action_219 (51) = happyGoto action_246
action_219 _ = happyReduce_100

action_220 _ = happyReduce_94

action_221 _ = happyReduce_96

action_222 (79) = happyShift action_22
action_222 (80) = happyShift action_43
action_222 (81) = happyShift action_25
action_222 (82) = happyShift action_44
action_222 (111) = happyShift action_221
action_222 (113) = happyShift action_222
action_222 (50) = happyGoto action_245
action_222 (53) = happyGoto action_218
action_222 (57) = happyGoto action_219
action_222 (59) = happyGoto action_220
action_222 _ = happyFail (happyExpListPerState 222)

action_223 _ = happyReduce_89

action_224 _ = happyReduce_69

action_225 _ = happyReduce_82

action_226 _ = happyReduce_45

action_227 _ = happyReduce_47

action_228 (86) = happyShift action_109
action_228 (42) = happyGoto action_244
action_228 _ = happyReduce_73

action_229 (114) = happyShift action_243
action_229 _ = happyFail (happyExpListPerState 229)

action_230 _ = happyReduce_27

action_231 (101) = happyShift action_19
action_231 (25) = happyGoto action_241
action_231 (26) = happyGoto action_242
action_231 _ = happyReduce_40

action_232 _ = happyReduce_108

action_233 _ = happyReduce_49

action_234 (101) = happyShift action_19
action_234 (26) = happyGoto action_11
action_234 (33) = happyGoto action_239
action_234 (35) = happyGoto action_240
action_234 _ = happyReduce_55

action_235 _ = happyReduce_24

action_236 _ = happyReduce_41

action_237 (79) = happyShift action_22
action_237 (81) = happyShift action_25
action_237 (113) = happyShift action_63
action_237 (54) = happyGoto action_238
action_237 (55) = happyGoto action_60
action_237 (56) = happyGoto action_61
action_237 (57) = happyGoto action_62
action_237 (59) = happyGoto action_56
action_237 _ = happyFail (happyExpListPerState 237)

action_238 _ = happyReduce_58

action_239 (116) = happyShift action_272
action_239 _ = happyFail (happyExpListPerState 239)

action_240 (101) = happyShift action_19
action_240 (26) = happyGoto action_11
action_240 (33) = happyGoto action_271
action_240 (35) = happyGoto action_240
action_240 _ = happyReduce_55

action_241 (116) = happyShift action_270
action_241 _ = happyFail (happyExpListPerState 241)

action_242 (106) = happyShift action_269
action_242 _ = happyFail (happyExpListPerState 242)

action_243 (115) = happyShift action_34
action_243 (38) = happyGoto action_268
action_243 _ = happyFail (happyExpListPerState 243)

action_244 (106) = happyShift action_267
action_244 _ = happyFail (happyExpListPerState 244)

action_245 (114) = happyShift action_266
action_245 _ = happyFail (happyExpListPerState 245)

action_246 _ = happyReduce_95

action_247 (79) = happyShift action_22
action_247 (80) = happyShift action_43
action_247 (81) = happyShift action_25
action_247 (82) = happyShift action_44
action_247 (111) = happyShift action_221
action_247 (113) = happyShift action_222
action_247 (50) = happyGoto action_264
action_247 (52) = happyGoto action_265
action_247 (53) = happyGoto action_218
action_247 (57) = happyGoto action_219
action_247 (59) = happyGoto action_220
action_247 _ = happyFail (happyExpListPerState 247)

action_248 (79) = happyShift action_22
action_248 (80) = happyShift action_43
action_248 (81) = happyShift action_25
action_248 (82) = happyShift action_44
action_248 (111) = happyShift action_221
action_248 (113) = happyShift action_222
action_248 (49) = happyGoto action_263
action_248 (50) = happyGoto action_217
action_248 (53) = happyGoto action_218
action_248 (57) = happyGoto action_219
action_248 (59) = happyGoto action_220
action_248 _ = happyFail (happyExpListPerState 248)

action_249 (79) = happyShift action_22
action_249 (80) = happyShift action_43
action_249 (81) = happyShift action_25
action_249 (82) = happyShift action_44
action_249 (85) = happyShift action_45
action_249 (98) = happyShift action_46
action_249 (100) = happyShift action_47
action_249 (103) = happyShift action_48
action_249 (104) = happyShift action_49
action_249 (113) = happyShift action_50
action_249 (39) = happyGoto action_262
action_249 (40) = happyGoto action_37
action_249 (43) = happyGoto action_38
action_249 (53) = happyGoto action_39
action_249 (57) = happyGoto action_40
action_249 (59) = happyGoto action_41
action_249 (60) = happyGoto action_42
action_249 _ = happyReduce_63

action_250 (115) = happyShift action_92
action_250 (61) = happyGoto action_261
action_250 _ = happyFail (happyExpListPerState 250)

action_251 _ = happyReduce_130

action_252 _ = happyReduce_129

action_253 (115) = happyShift action_92
action_253 (61) = happyGoto action_260
action_253 _ = happyFail (happyExpListPerState 253)

action_254 (115) = happyShift action_92
action_254 (61) = happyGoto action_259
action_254 _ = happyFail (happyExpListPerState 254)

action_255 _ = happyReduce_137

action_256 _ = happyReduce_145

action_257 (79) = happyShift action_22
action_257 (80) = happyShift action_123
action_257 (82) = happyShift action_124
action_257 (59) = happyGoto action_183
action_257 (74) = happyGoto action_204
action_257 (76) = happyGoto action_258
action_257 (77) = happyGoto action_122
action_257 _ = happyReduce_147

action_258 _ = happyReduce_148

action_259 _ = happyReduce_128

action_260 _ = happyReduce_133

action_261 _ = happyReduce_132

action_262 _ = happyReduce_91

action_263 _ = happyReduce_93

action_264 (109) = happyShift action_275
action_264 _ = happyReduce_101

action_265 (118) = happyShift action_274
action_265 _ = happyFail (happyExpListPerState 265)

action_266 _ = happyReduce_98

action_267 _ = happyReduce_22

action_268 _ = happyReduce_60

action_269 (101) = happyShift action_19
action_269 (25) = happyGoto action_273
action_269 (26) = happyGoto action_242
action_269 _ = happyReduce_40

action_270 _ = happyReduce_28

action_271 _ = happyReduce_54

action_272 _ = happyReduce_56

action_273 _ = happyReduce_39

action_274 _ = happyReduce_99

action_275 (79) = happyShift action_22
action_275 (80) = happyShift action_43
action_275 (81) = happyShift action_25
action_275 (82) = happyShift action_44
action_275 (111) = happyShift action_221
action_275 (113) = happyShift action_222
action_275 (50) = happyGoto action_264
action_275 (52) = happyGoto action_276
action_275 (53) = happyGoto action_218
action_275 (57) = happyGoto action_219
action_275 (59) = happyGoto action_220
action_275 _ = happyFail (happyExpListPerState 275)

action_276 _ = happyReduce_102

happyReduce_1 = happySpecReduce_2  4 happyReduction_1
happyReduction_1 (HappyAbsSyn7  happy_var_2)
	(HappyAbsSyn5  happy_var_1)
	 =  HappyAbsSyn4
		 (CompUnit happy_var_1 happy_var_2
	)
happyReduction_1 _ _  = notHappyAtAll 

happyReduce_2 = happySpecReduce_2  5 happyReduction_2
happyReduction_2 (HappyAbsSyn6  happy_var_2)
	(HappyAbsSyn5  happy_var_1)
	 =  HappyAbsSyn5
		 (happy_var_2 : happy_var_1
	)
happyReduction_2 _ _  = notHappyAtAll 

happyReduce_3 = happySpecReduce_0  5 happyReduction_3
happyReduction_3  =  HappyAbsSyn5
		 ([]
	)

happyReduce_4 = happySpecReduce_3  6 happyReduction_4
happyReduction_4 _
	(HappyAbsSyn58  happy_var_2)
	_
	 =  HappyAbsSyn6
		 (Import (QualName happy_var_2)
	)
happyReduction_4 _ _ _  = notHappyAtAll 

happyReduce_5 = happySpecReduce_2  7 happyReduction_5
happyReduction_5 (HappyAbsSyn7  happy_var_2)
	(HappyAbsSyn8  happy_var_1)
	 =  HappyAbsSyn7
		 (happy_var_1 : happy_var_2
	)
happyReduction_5 _ _  = notHappyAtAll 

happyReduce_6 = happySpecReduce_0  7 happyReduction_6
happyReduction_6  =  HappyAbsSyn7
		 ([]
	)

happyReduce_7 = happySpecReduce_1  8 happyReduction_7
happyReduction_7 (HappyAbsSyn9  happy_var_1)
	 =  HappyAbsSyn8
		 (TContr happy_var_1
	)
happyReduction_7 _  = notHappyAtAll 

happyReduce_8 = happySpecReduce_1  8 happyReduction_8
happyReduction_8 (HappyAbsSyn35  happy_var_1)
	 =  HappyAbsSyn8
		 (TFunDef happy_var_1
	)
happyReduction_8 _  = notHappyAtAll 

happyReduce_9 = happySpecReduce_1  8 happyReduction_9
happyReduction_9 (HappyAbsSyn17  happy_var_1)
	 =  HappyAbsSyn8
		 (TClassDef happy_var_1
	)
happyReduction_9 _  = notHappyAtAll 

happyReduce_10 = happySpecReduce_1  8 happyReduction_10
happyReduction_10 (HappyAbsSyn30  happy_var_1)
	 =  HappyAbsSyn8
		 (TInstDef happy_var_1
	)
happyReduction_10 _  = notHappyAtAll 

happyReduce_11 = happySpecReduce_1  8 happyReduction_11
happyReduction_11 (HappyAbsSyn14  happy_var_1)
	 =  HappyAbsSyn8
		 (TDataDef happy_var_1
	)
happyReduction_11 _  = notHappyAtAll 

happyReduce_12 = happySpecReduce_1  8 happyReduction_12
happyReduction_12 (HappyAbsSyn12  happy_var_1)
	 =  HappyAbsSyn8
		 (TSym happy_var_1
	)
happyReduction_12 _  = notHappyAtAll 

happyReduce_13 = happyReduce 6 9 happyReduction_13
happyReduction_13 (_ `HappyStk`
	(HappyAbsSyn10  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn19  happy_var_3) `HappyStk`
	(HappyAbsSyn57  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn9
		 (Contract happy_var_2 happy_var_3 happy_var_5
	) `HappyStk` happyRest

happyReduce_14 = happySpecReduce_2  10 happyReduction_14
happyReduction_14 (HappyAbsSyn10  happy_var_2)
	(HappyAbsSyn11  happy_var_1)
	 =  HappyAbsSyn10
		 (happy_var_1 : happy_var_2
	)
happyReduction_14 _ _  = notHappyAtAll 

happyReduce_15 = happySpecReduce_0  10 happyReduction_15
happyReduction_15  =  HappyAbsSyn10
		 ([]
	)

happyReduce_16 = happySpecReduce_1  11 happyReduction_16
happyReduction_16 (HappyAbsSyn13  happy_var_1)
	 =  HappyAbsSyn11
		 (CFieldDecl happy_var_1
	)
happyReduction_16 _  = notHappyAtAll 

happyReduce_17 = happySpecReduce_1  11 happyReduction_17
happyReduction_17 (HappyAbsSyn14  happy_var_1)
	 =  HappyAbsSyn11
		 (CDataDecl happy_var_1
	)
happyReduction_17 _  = notHappyAtAll 

happyReduce_18 = happySpecReduce_1  11 happyReduction_18
happyReduction_18 (HappyAbsSyn35  happy_var_1)
	 =  HappyAbsSyn11
		 (CFunDecl happy_var_1
	)
happyReduction_18 _  = notHappyAtAll 

happyReduce_19 = happySpecReduce_1  11 happyReduction_19
happyReduction_19 (HappyAbsSyn37  happy_var_1)
	 =  HappyAbsSyn11
		 (CConstrDecl happy_var_1
	)
happyReduction_19 _  = notHappyAtAll 

happyReduce_20 = happySpecReduce_1  11 happyReduction_20
happyReduction_20 (HappyAbsSyn12  happy_var_1)
	 =  HappyAbsSyn11
		 (CSym happy_var_1
	)
happyReduction_20 _  = notHappyAtAll 

happyReduce_21 = happyReduce 4 12 happyReduction_21
happyReduction_21 ((HappyAbsSyn54  happy_var_4) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn57  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn12
		 (TySym happy_var_2 happy_var_4
	) `HappyStk` happyRest

happyReduce_22 = happyReduce 5 13 happyReduction_22
happyReduction_22 (_ `HappyStk`
	(HappyAbsSyn42  happy_var_4) `HappyStk`
	(HappyAbsSyn54  happy_var_3) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn57  happy_var_1) `HappyStk`
	happyRest)
	 = HappyAbsSyn13
		 (Field happy_var_1 happy_var_3 happy_var_4
	) `HappyStk` happyRest

happyReduce_23 = happyReduce 5 14 happyReduction_23
happyReduction_23 ((HappyAbsSyn15  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn19  happy_var_3) `HappyStk`
	(HappyAbsSyn57  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn14
		 (DataTy happy_var_2 happy_var_3 happy_var_5
	) `HappyStk` happyRest

happyReduce_24 = happySpecReduce_3  15 happyReduction_24
happyReduction_24 (HappyAbsSyn15  happy_var_3)
	_
	(HappyAbsSyn16  happy_var_1)
	 =  HappyAbsSyn15
		 (happy_var_1 : happy_var_3
	)
happyReduction_24 _ _ _  = notHappyAtAll 

happyReduce_25 = happySpecReduce_1  15 happyReduction_25
happyReduction_25 (HappyAbsSyn16  happy_var_1)
	 =  HappyAbsSyn15
		 ([happy_var_1]
	)
happyReduction_25 _  = notHappyAtAll 

happyReduce_26 = happySpecReduce_2  16 happyReduction_26
happyReduction_26 (HappyAbsSyn31  happy_var_2)
	(HappyAbsSyn57  happy_var_1)
	 =  HappyAbsSyn16
		 (Constr happy_var_1 happy_var_2
	)
happyReduction_26 _ _  = notHappyAtAll 

happyReduce_27 = happyReduce 7 17 happyReduction_27
happyReduction_27 ((HappyAbsSyn18  happy_var_7) `HappyStk`
	(HappyAbsSyn19  happy_var_6) `HappyStk`
	(HappyAbsSyn57  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn56  happy_var_3) `HappyStk`
	(HappyAbsSyn21  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn17
		 (Class happy_var_2 happy_var_5 happy_var_6 happy_var_3 happy_var_7
	) `HappyStk` happyRest

happyReduce_28 = happySpecReduce_3  18 happyReduction_28
happyReduction_28 _
	(HappyAbsSyn18  happy_var_2)
	_
	 =  HappyAbsSyn18
		 (happy_var_2
	)
happyReduction_28 _ _ _  = notHappyAtAll 

happyReduce_29 = happySpecReduce_3  19 happyReduction_29
happyReduction_29 _
	(HappyAbsSyn19  happy_var_2)
	_
	 =  HappyAbsSyn19
		 (happy_var_2
	)
happyReduction_29 _ _ _  = notHappyAtAll 

happyReduce_30 = happySpecReduce_0  19 happyReduction_30
happyReduction_30  =  HappyAbsSyn19
		 ([]
	)

happyReduce_31 = happySpecReduce_3  20 happyReduction_31
happyReduction_31 (HappyAbsSyn19  happy_var_3)
	_
	(HappyAbsSyn56  happy_var_1)
	 =  HappyAbsSyn19
		 (happy_var_1 : happy_var_3
	)
happyReduction_31 _ _ _  = notHappyAtAll 

happyReduce_32 = happySpecReduce_1  20 happyReduction_32
happyReduction_32 (HappyAbsSyn56  happy_var_1)
	 =  HappyAbsSyn19
		 ([happy_var_1]
	)
happyReduction_32 _  = notHappyAtAll 

happyReduce_33 = happySpecReduce_0  21 happyReduction_33
happyReduction_33  =  HappyAbsSyn21
		 ([]
	)

happyReduce_34 = happySpecReduce_1  21 happyReduction_34
happyReduction_34 (HappyAbsSyn21  happy_var_1)
	 =  HappyAbsSyn21
		 (happy_var_1
	)
happyReduction_34 _  = notHappyAtAll 

happyReduce_35 = happyReduce 4 22 happyReduction_35
happyReduction_35 (_ `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn21  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn21
		 (happy_var_2
	) `HappyStk` happyRest

happyReduce_36 = happySpecReduce_3  23 happyReduction_36
happyReduction_36 (HappyAbsSyn21  happy_var_3)
	_
	(HappyAbsSyn24  happy_var_1)
	 =  HappyAbsSyn21
		 (happy_var_1 : happy_var_3
	)
happyReduction_36 _ _ _  = notHappyAtAll 

happyReduce_37 = happySpecReduce_1  23 happyReduction_37
happyReduction_37 (HappyAbsSyn24  happy_var_1)
	 =  HappyAbsSyn21
		 ([happy_var_1]
	)
happyReduction_37 _  = notHappyAtAll 

happyReduce_38 = happyReduce 4 24 happyReduction_38
happyReduction_38 ((HappyAbsSyn31  happy_var_4) `HappyStk`
	(HappyAbsSyn57  happy_var_3) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn54  happy_var_1) `HappyStk`
	happyRest)
	 = HappyAbsSyn24
		 (InCls happy_var_3 happy_var_1 happy_var_4
	) `HappyStk` happyRest

happyReduce_39 = happySpecReduce_3  25 happyReduction_39
happyReduction_39 (HappyAbsSyn18  happy_var_3)
	_
	(HappyAbsSyn26  happy_var_1)
	 =  HappyAbsSyn18
		 (happy_var_1 : happy_var_3
	)
happyReduction_39 _ _ _  = notHappyAtAll 

happyReduce_40 = happySpecReduce_0  25 happyReduction_40
happyReduction_40  =  HappyAbsSyn18
		 ([]
	)

happyReduce_41 = happyReduce 7 26 happyReduction_41
happyReduction_41 ((HappyAbsSyn36  happy_var_7) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn28  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn21  happy_var_3) `HappyStk`
	(HappyAbsSyn57  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn26
		 (Signature happy_var_2 happy_var_3 happy_var_5 happy_var_7
	) `HappyStk` happyRest

happyReduce_42 = happySpecReduce_0  27 happyReduction_42
happyReduction_42  =  HappyAbsSyn21
		 ([]
	)

happyReduce_43 = happySpecReduce_3  27 happyReduction_43
happyReduction_43 _
	(HappyAbsSyn21  happy_var_2)
	_
	 =  HappyAbsSyn21
		 (happy_var_2
	)
happyReduction_43 _ _ _  = notHappyAtAll 

happyReduce_44 = happySpecReduce_1  28 happyReduction_44
happyReduction_44 (HappyAbsSyn29  happy_var_1)
	 =  HappyAbsSyn28
		 ([happy_var_1]
	)
happyReduction_44 _  = notHappyAtAll 

happyReduce_45 = happySpecReduce_3  28 happyReduction_45
happyReduction_45 (HappyAbsSyn28  happy_var_3)
	_
	(HappyAbsSyn29  happy_var_1)
	 =  HappyAbsSyn28
		 (happy_var_1 : happy_var_3
	)
happyReduction_45 _ _ _  = notHappyAtAll 

happyReduce_46 = happySpecReduce_0  28 happyReduction_46
happyReduction_46  =  HappyAbsSyn28
		 ([]
	)

happyReduce_47 = happySpecReduce_3  29 happyReduction_47
happyReduction_47 (HappyAbsSyn54  happy_var_3)
	_
	(HappyAbsSyn57  happy_var_1)
	 =  HappyAbsSyn29
		 (Typed happy_var_1 happy_var_3
	)
happyReduction_47 _ _ _  = notHappyAtAll 

happyReduce_48 = happySpecReduce_1  29 happyReduction_48
happyReduction_48 (HappyAbsSyn57  happy_var_1)
	 =  HappyAbsSyn29
		 (Untyped happy_var_1
	)
happyReduction_48 _  = notHappyAtAll 

happyReduce_49 = happyReduce 7 30 happyReduction_49
happyReduction_49 ((HappyAbsSyn33  happy_var_7) `HappyStk`
	(HappyAbsSyn31  happy_var_6) `HappyStk`
	(HappyAbsSyn57  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn54  happy_var_3) `HappyStk`
	(HappyAbsSyn21  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn30
		 (Instance happy_var_2 happy_var_5 happy_var_6 happy_var_3 happy_var_7
	) `HappyStk` happyRest

happyReduce_50 = happySpecReduce_3  31 happyReduction_50
happyReduction_50 _
	(HappyAbsSyn31  happy_var_2)
	_
	 =  HappyAbsSyn31
		 (happy_var_2
	)
happyReduction_50 _ _ _  = notHappyAtAll 

happyReduce_51 = happySpecReduce_0  31 happyReduction_51
happyReduction_51  =  HappyAbsSyn31
		 ([]
	)

happyReduce_52 = happySpecReduce_3  32 happyReduction_52
happyReduction_52 (HappyAbsSyn31  happy_var_3)
	_
	(HappyAbsSyn54  happy_var_1)
	 =  HappyAbsSyn31
		 (happy_var_1 : happy_var_3
	)
happyReduction_52 _ _ _  = notHappyAtAll 

happyReduce_53 = happySpecReduce_1  32 happyReduction_53
happyReduction_53 (HappyAbsSyn54  happy_var_1)
	 =  HappyAbsSyn31
		 ([happy_var_1]
	)
happyReduction_53 _  = notHappyAtAll 

happyReduce_54 = happySpecReduce_2  33 happyReduction_54
happyReduction_54 (HappyAbsSyn33  happy_var_2)
	(HappyAbsSyn35  happy_var_1)
	 =  HappyAbsSyn33
		 (happy_var_1 : happy_var_2
	)
happyReduction_54 _ _  = notHappyAtAll 

happyReduce_55 = happySpecReduce_0  33 happyReduction_55
happyReduction_55  =  HappyAbsSyn33
		 ([]
	)

happyReduce_56 = happySpecReduce_3  34 happyReduction_56
happyReduction_56 _
	(HappyAbsSyn33  happy_var_2)
	_
	 =  HappyAbsSyn33
		 (happy_var_2
	)
happyReduction_56 _ _ _  = notHappyAtAll 

happyReduce_57 = happySpecReduce_2  35 happyReduction_57
happyReduction_57 (HappyAbsSyn38  happy_var_2)
	(HappyAbsSyn26  happy_var_1)
	 =  HappyAbsSyn35
		 (FunDef happy_var_1 happy_var_2
	)
happyReduction_57 _ _  = notHappyAtAll 

happyReduce_58 = happySpecReduce_2  36 happyReduction_58
happyReduction_58 (HappyAbsSyn54  happy_var_2)
	_
	 =  HappyAbsSyn36
		 (Just happy_var_2
	)
happyReduction_58 _ _  = notHappyAtAll 

happyReduce_59 = happySpecReduce_0  36 happyReduction_59
happyReduction_59  =  HappyAbsSyn36
		 (Nothing
	)

happyReduce_60 = happyReduce 5 37 happyReduction_60
happyReduction_60 ((HappyAbsSyn38  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn28  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn37
		 (Constructor happy_var_3 happy_var_5
	) `HappyStk` happyRest

happyReduce_61 = happySpecReduce_3  38 happyReduction_61
happyReduction_61 _
	(HappyAbsSyn38  happy_var_2)
	_
	 =  HappyAbsSyn38
		 (happy_var_2
	)
happyReduction_61 _ _ _  = notHappyAtAll 

happyReduce_62 = happySpecReduce_3  39 happyReduction_62
happyReduction_62 (HappyAbsSyn38  happy_var_3)
	_
	(HappyAbsSyn40  happy_var_1)
	 =  HappyAbsSyn38
		 (happy_var_1 : happy_var_3
	)
happyReduction_62 _ _ _  = notHappyAtAll 

happyReduce_63 = happySpecReduce_0  39 happyReduction_63
happyReduction_63  =  HappyAbsSyn38
		 ([]
	)

happyReduce_64 = happySpecReduce_3  40 happyReduction_64
happyReduction_64 (HappyAbsSyn43  happy_var_3)
	_
	(HappyAbsSyn43  happy_var_1)
	 =  HappyAbsSyn40
		 (happy_var_1 := happy_var_3
	)
happyReduction_64 _ _ _  = notHappyAtAll 

happyReduce_65 = happyReduce 5 40 happyReduction_65
happyReduction_65 ((HappyAbsSyn42  happy_var_5) `HappyStk`
	(HappyAbsSyn54  happy_var_4) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn57  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn40
		 (Let happy_var_2 (Just happy_var_4) happy_var_5
	) `HappyStk` happyRest

happyReduce_66 = happySpecReduce_3  40 happyReduction_66
happyReduction_66 (HappyAbsSyn42  happy_var_3)
	(HappyAbsSyn57  happy_var_2)
	_
	 =  HappyAbsSyn40
		 (Let happy_var_2 Nothing happy_var_3
	)
happyReduction_66 _ _ _  = notHappyAtAll 

happyReduce_67 = happySpecReduce_1  40 happyReduction_67
happyReduction_67 (HappyAbsSyn43  happy_var_1)
	 =  HappyAbsSyn40
		 (StmtExp happy_var_1
	)
happyReduction_67 _  = notHappyAtAll 

happyReduce_68 = happySpecReduce_2  40 happyReduction_68
happyReduction_68 (HappyAbsSyn43  happy_var_2)
	_
	 =  HappyAbsSyn40
		 (Return happy_var_2
	)
happyReduction_68 _ _  = notHappyAtAll 

happyReduce_69 = happyReduce 5 40 happyReduction_69
happyReduction_69 (_ `HappyStk`
	(HappyAbsSyn47  happy_var_4) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn41  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn40
		 (Match happy_var_2 happy_var_4
	) `HappyStk` happyRest

happyReduce_70 = happySpecReduce_1  40 happyReduction_70
happyReduction_70 (HappyAbsSyn60  happy_var_1)
	 =  HappyAbsSyn40
		 (Asm happy_var_1
	)
happyReduction_70 _  = notHappyAtAll 

happyReduce_71 = happySpecReduce_1  41 happyReduction_71
happyReduction_71 (HappyAbsSyn43  happy_var_1)
	 =  HappyAbsSyn41
		 ([happy_var_1]
	)
happyReduction_71 _  = notHappyAtAll 

happyReduce_72 = happySpecReduce_3  41 happyReduction_72
happyReduction_72 (HappyAbsSyn41  happy_var_3)
	_
	(HappyAbsSyn43  happy_var_1)
	 =  HappyAbsSyn41
		 (happy_var_1 : happy_var_3
	)
happyReduction_72 _ _ _  = notHappyAtAll 

happyReduce_73 = happySpecReduce_0  42 happyReduction_73
happyReduction_73  =  HappyAbsSyn42
		 (Nothing
	)

happyReduce_74 = happySpecReduce_2  42 happyReduction_74
happyReduction_74 (HappyAbsSyn43  happy_var_2)
	_
	 =  HappyAbsSyn42
		 (Just happy_var_2
	)
happyReduction_74 _ _  = notHappyAtAll 

happyReduce_75 = happySpecReduce_1  43 happyReduction_75
happyReduction_75 (HappyAbsSyn57  happy_var_1)
	 =  HappyAbsSyn43
		 (Var happy_var_1
	)
happyReduction_75 _  = notHappyAtAll 

happyReduce_76 = happySpecReduce_2  43 happyReduction_76
happyReduction_76 (HappyAbsSyn41  happy_var_2)
	(HappyAbsSyn57  happy_var_1)
	 =  HappyAbsSyn43
		 (Con happy_var_1 happy_var_2
	)
happyReduction_76 _ _  = notHappyAtAll 

happyReduce_77 = happySpecReduce_1  43 happyReduction_77
happyReduction_77 (HappyAbsSyn53  happy_var_1)
	 =  HappyAbsSyn43
		 (Lit happy_var_1
	)
happyReduction_77 _  = notHappyAtAll 

happyReduce_78 = happySpecReduce_3  43 happyReduction_78
happyReduction_78 _
	(HappyAbsSyn43  happy_var_2)
	_
	 =  HappyAbsSyn43
		 (happy_var_2
	)
happyReduction_78 _ _ _  = notHappyAtAll 

happyReduce_79 = happySpecReduce_3  43 happyReduction_79
happyReduction_79 (HappyAbsSyn57  happy_var_3)
	_
	(HappyAbsSyn43  happy_var_1)
	 =  HappyAbsSyn43
		 (FieldAccess happy_var_1 happy_var_3
	)
happyReduction_79 _ _ _  = notHappyAtAll 

happyReduce_80 = happyReduce 4 43 happyReduction_80
happyReduction_80 ((HappyAbsSyn41  happy_var_4) `HappyStk`
	(HappyAbsSyn57  happy_var_3) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn43  happy_var_1) `HappyStk`
	happyRest)
	 = HappyAbsSyn43
		 (Call (Just happy_var_1) happy_var_3 happy_var_4
	) `HappyStk` happyRest

happyReduce_81 = happySpecReduce_2  43 happyReduction_81
happyReduction_81 (HappyAbsSyn41  happy_var_2)
	(HappyAbsSyn57  happy_var_1)
	 =  HappyAbsSyn43
		 (Call Nothing happy_var_1 happy_var_2
	)
happyReduction_81 _ _  = notHappyAtAll 

happyReduce_82 = happyReduce 5 43 happyReduction_82
happyReduction_82 ((HappyAbsSyn38  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn28  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn43
		 (Lam happy_var_3 happy_var_5 Nothing
	) `HappyStk` happyRest

happyReduce_83 = happySpecReduce_3  44 happyReduction_83
happyReduction_83 _
	(HappyAbsSyn41  happy_var_2)
	_
	 =  HappyAbsSyn41
		 (happy_var_2
	)
happyReduction_83 _ _ _  = notHappyAtAll 

happyReduce_84 = happySpecReduce_0  44 happyReduction_84
happyReduction_84  =  HappyAbsSyn41
		 ([]
	)

happyReduce_85 = happySpecReduce_3  45 happyReduction_85
happyReduction_85 _
	(HappyAbsSyn41  happy_var_2)
	_
	 =  HappyAbsSyn41
		 (happy_var_2
	)
happyReduction_85 _ _ _  = notHappyAtAll 

happyReduce_86 = happySpecReduce_1  46 happyReduction_86
happyReduction_86 (HappyAbsSyn43  happy_var_1)
	 =  HappyAbsSyn41
		 ([happy_var_1]
	)
happyReduction_86 _  = notHappyAtAll 

happyReduce_87 = happySpecReduce_0  46 happyReduction_87
happyReduction_87  =  HappyAbsSyn41
		 ([]
	)

happyReduce_88 = happySpecReduce_3  46 happyReduction_88
happyReduction_88 (HappyAbsSyn41  happy_var_3)
	_
	(HappyAbsSyn43  happy_var_1)
	 =  HappyAbsSyn41
		 (happy_var_1 : happy_var_3
	)
happyReduction_88 _ _ _  = notHappyAtAll 

happyReduce_89 = happySpecReduce_2  47 happyReduction_89
happyReduction_89 (HappyAbsSyn47  happy_var_2)
	(HappyAbsSyn48  happy_var_1)
	 =  HappyAbsSyn47
		 (happy_var_1 : happy_var_2
	)
happyReduction_89 _ _  = notHappyAtAll 

happyReduce_90 = happySpecReduce_0  47 happyReduction_90
happyReduction_90  =  HappyAbsSyn47
		 ([]
	)

happyReduce_91 = happyReduce 4 48 happyReduction_91
happyReduction_91 ((HappyAbsSyn38  happy_var_4) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn49  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn48
		 ((happy_var_2, happy_var_4)
	) `HappyStk` happyRest

happyReduce_92 = happySpecReduce_1  49 happyReduction_92
happyReduction_92 (HappyAbsSyn50  happy_var_1)
	 =  HappyAbsSyn49
		 ([happy_var_1]
	)
happyReduction_92 _  = notHappyAtAll 

happyReduce_93 = happySpecReduce_3  49 happyReduction_93
happyReduction_93 (HappyAbsSyn49  happy_var_3)
	_
	(HappyAbsSyn50  happy_var_1)
	 =  HappyAbsSyn49
		 (happy_var_1 : happy_var_3
	)
happyReduction_93 _ _ _  = notHappyAtAll 

happyReduce_94 = happySpecReduce_1  50 happyReduction_94
happyReduction_94 (HappyAbsSyn57  happy_var_1)
	 =  HappyAbsSyn50
		 (PVar happy_var_1
	)
happyReduction_94 _  = notHappyAtAll 

happyReduce_95 = happySpecReduce_2  50 happyReduction_95
happyReduction_95 (HappyAbsSyn49  happy_var_2)
	(HappyAbsSyn57  happy_var_1)
	 =  HappyAbsSyn50
		 (PCon happy_var_1 happy_var_2
	)
happyReduction_95 _ _  = notHappyAtAll 

happyReduce_96 = happySpecReduce_1  50 happyReduction_96
happyReduction_96 _
	 =  HappyAbsSyn50
		 (PWildcard
	)

happyReduce_97 = happySpecReduce_1  50 happyReduction_97
happyReduction_97 (HappyAbsSyn53  happy_var_1)
	 =  HappyAbsSyn50
		 (PLit happy_var_1
	)
happyReduction_97 _  = notHappyAtAll 

happyReduce_98 = happySpecReduce_3  50 happyReduction_98
happyReduction_98 _
	(HappyAbsSyn50  happy_var_2)
	_
	 =  HappyAbsSyn50
		 (happy_var_2
	)
happyReduction_98 _ _ _  = notHappyAtAll 

happyReduce_99 = happySpecReduce_3  51 happyReduction_99
happyReduction_99 _
	(HappyAbsSyn49  happy_var_2)
	_
	 =  HappyAbsSyn49
		 (happy_var_2
	)
happyReduction_99 _ _ _  = notHappyAtAll 

happyReduce_100 = happySpecReduce_0  51 happyReduction_100
happyReduction_100  =  HappyAbsSyn49
		 ([]
	)

happyReduce_101 = happySpecReduce_1  52 happyReduction_101
happyReduction_101 (HappyAbsSyn50  happy_var_1)
	 =  HappyAbsSyn49
		 ([happy_var_1]
	)
happyReduction_101 _  = notHappyAtAll 

happyReduce_102 = happySpecReduce_3  52 happyReduction_102
happyReduction_102 (HappyAbsSyn49  happy_var_3)
	_
	(HappyAbsSyn50  happy_var_1)
	 =  HappyAbsSyn49
		 (happy_var_1 : happy_var_3
	)
happyReduction_102 _ _ _  = notHappyAtAll 

happyReduce_103 = happySpecReduce_1  53 happyReduction_103
happyReduction_103 (HappyTerminal (Token _ (TNumber happy_var_1)))
	 =  HappyAbsSyn53
		 (IntLit $ toInteger happy_var_1
	)
happyReduction_103 _  = notHappyAtAll 

happyReduce_104 = happySpecReduce_1  53 happyReduction_104
happyReduction_104 (HappyTerminal (Token _ (TString happy_var_1)))
	 =  HappyAbsSyn53
		 (StrLit happy_var_1
	)
happyReduction_104 _  = notHappyAtAll 

happyReduce_105 = happySpecReduce_2  54 happyReduction_105
happyReduction_105 (HappyAbsSyn31  happy_var_2)
	(HappyAbsSyn57  happy_var_1)
	 =  HappyAbsSyn54
		 (TyCon happy_var_1 happy_var_2
	)
happyReduction_105 _ _  = notHappyAtAll 

happyReduce_106 = happySpecReduce_1  54 happyReduction_106
happyReduction_106 (HappyAbsSyn56  happy_var_1)
	 =  HappyAbsSyn54
		 (TyVar  happy_var_1
	)
happyReduction_106 _  = notHappyAtAll 

happyReduce_107 = happySpecReduce_1  54 happyReduction_107
happyReduction_107 (HappyAbsSyn55  happy_var_1)
	 =  HappyAbsSyn54
		 (uncurry funtype happy_var_1
	)
happyReduction_107 _  = notHappyAtAll 

happyReduce_108 = happyReduce 5 55 happyReduction_108
happyReduction_108 ((HappyAbsSyn54  happy_var_5) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn31  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn55
		 ((happy_var_2, happy_var_5)
	) `HappyStk` happyRest

happyReduce_109 = happySpecReduce_1  56 happyReduction_109
happyReduction_109 (HappyAbsSyn57  happy_var_1)
	 =  HappyAbsSyn56
		 (TVar happy_var_1
	)
happyReduction_109 _  = notHappyAtAll 

happyReduce_110 = happySpecReduce_1  57 happyReduction_110
happyReduction_110 (HappyTerminal (Token _ (TTycon happy_var_1)))
	 =  HappyAbsSyn57
		 (Name happy_var_1
	)
happyReduction_110 _  = notHappyAtAll 

happyReduce_111 = happySpecReduce_1  58 happyReduction_111
happyReduction_111 (HappyAbsSyn57  happy_var_1)
	 =  HappyAbsSyn58
		 ([happy_var_1]
	)
happyReduction_111 _  = notHappyAtAll 

happyReduce_112 = happySpecReduce_3  58 happyReduction_112
happyReduction_112 (HappyAbsSyn57  happy_var_3)
	_
	(HappyAbsSyn58  happy_var_1)
	 =  HappyAbsSyn58
		 (happy_var_3 : happy_var_1
	)
happyReduction_112 _ _ _  = notHappyAtAll 

happyReduce_113 = happySpecReduce_1  59 happyReduction_113
happyReduction_113 (HappyTerminal (Token _ (TIdent happy_var_1)))
	 =  HappyAbsSyn57
		 (Name happy_var_1
	)
happyReduction_113 _  = notHappyAtAll 

happyReduce_114 = happySpecReduce_2  60 happyReduction_114
happyReduction_114 (HappyAbsSyn60  happy_var_2)
	_
	 =  HappyAbsSyn60
		 (happy_var_2
	)
happyReduction_114 _ _  = notHappyAtAll 

happyReduce_115 = happySpecReduce_3  61 happyReduction_115
happyReduction_115 _
	(HappyAbsSyn62  happy_var_2)
	_
	 =  HappyAbsSyn60
		 (happy_var_2
	)
happyReduction_115 _ _ _  = notHappyAtAll 

happyReduce_116 = happySpecReduce_3  62 happyReduction_116
happyReduction_116 (HappyAbsSyn62  happy_var_3)
	_
	(HappyAbsSyn63  happy_var_1)
	 =  HappyAbsSyn62
		 (happy_var_1 : happy_var_3
	)
happyReduction_116 _ _ _  = notHappyAtAll 

happyReduce_117 = happySpecReduce_0  62 happyReduction_117
happyReduction_117  =  HappyAbsSyn62
		 ([]
	)

happyReduce_118 = happySpecReduce_1  63 happyReduction_118
happyReduction_118 (HappyAbsSyn63  happy_var_1)
	 =  HappyAbsSyn63
		 (happy_var_1
	)
happyReduction_118 _  = notHappyAtAll 

happyReduce_119 = happySpecReduce_1  63 happyReduction_119
happyReduction_119 (HappyAbsSyn60  happy_var_1)
	 =  HappyAbsSyn63
		 (YBlock happy_var_1
	)
happyReduction_119 _  = notHappyAtAll 

happyReduce_120 = happySpecReduce_1  63 happyReduction_120
happyReduction_120 (HappyAbsSyn63  happy_var_1)
	 =  HappyAbsSyn63
		 (happy_var_1
	)
happyReduction_120 _  = notHappyAtAll 

happyReduce_121 = happySpecReduce_1  63 happyReduction_121
happyReduction_121 (HappyAbsSyn74  happy_var_1)
	 =  HappyAbsSyn63
		 (YExp happy_var_1
	)
happyReduction_121 _  = notHappyAtAll 

happyReduce_122 = happySpecReduce_1  63 happyReduction_122
happyReduction_122 (HappyAbsSyn63  happy_var_1)
	 =  HappyAbsSyn63
		 (happy_var_1
	)
happyReduction_122 _  = notHappyAtAll 

happyReduce_123 = happySpecReduce_1  63 happyReduction_123
happyReduction_123 (HappyAbsSyn63  happy_var_1)
	 =  HappyAbsSyn63
		 (happy_var_1
	)
happyReduction_123 _  = notHappyAtAll 

happyReduce_124 = happySpecReduce_1  63 happyReduction_124
happyReduction_124 (HappyAbsSyn63  happy_var_1)
	 =  HappyAbsSyn63
		 (happy_var_1
	)
happyReduction_124 _  = notHappyAtAll 

happyReduce_125 = happySpecReduce_1  63 happyReduction_125
happyReduction_125 _
	 =  HappyAbsSyn63
		 (YContinue
	)

happyReduce_126 = happySpecReduce_1  63 happyReduction_126
happyReduction_126 _
	 =  HappyAbsSyn63
		 (YBreak
	)

happyReduce_127 = happySpecReduce_1  63 happyReduction_127
happyReduction_127 _
	 =  HappyAbsSyn63
		 (YLeave
	)

happyReduce_128 = happyReduce 5 64 happyReduction_128
happyReduction_128 ((HappyAbsSyn60  happy_var_5) `HappyStk`
	(HappyAbsSyn60  happy_var_4) `HappyStk`
	(HappyAbsSyn74  happy_var_3) `HappyStk`
	(HappyAbsSyn60  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn63
		 (YFor happy_var_2 happy_var_3 happy_var_4 happy_var_5
	) `HappyStk` happyRest

happyReduce_129 = happyReduce 4 65 happyReduction_129
happyReduction_129 ((HappyAbsSyn68  happy_var_4) `HappyStk`
	(HappyAbsSyn66  happy_var_3) `HappyStk`
	(HappyAbsSyn74  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn63
		 (YSwitch happy_var_2 happy_var_3 happy_var_4
	) `HappyStk` happyRest

happyReduce_130 = happySpecReduce_2  66 happyReduction_130
happyReduction_130 (HappyAbsSyn66  happy_var_2)
	(HappyAbsSyn67  happy_var_1)
	 =  HappyAbsSyn66
		 (happy_var_1 : happy_var_2
	)
happyReduction_130 _ _  = notHappyAtAll 

happyReduce_131 = happySpecReduce_0  66 happyReduction_131
happyReduction_131  =  HappyAbsSyn66
		 ([]
	)

happyReduce_132 = happySpecReduce_3  67 happyReduction_132
happyReduction_132 (HappyAbsSyn60  happy_var_3)
	(HappyAbsSyn77  happy_var_2)
	_
	 =  HappyAbsSyn67
		 ((happy_var_2, happy_var_3)
	)
happyReduction_132 _ _ _  = notHappyAtAll 

happyReduce_133 = happySpecReduce_2  68 happyReduction_133
happyReduction_133 (HappyAbsSyn60  happy_var_2)
	_
	 =  HappyAbsSyn68
		 (Just happy_var_2
	)
happyReduction_133 _ _  = notHappyAtAll 

happyReduce_134 = happySpecReduce_0  68 happyReduction_134
happyReduction_134  =  HappyAbsSyn68
		 (Nothing
	)

happyReduce_135 = happySpecReduce_3  69 happyReduction_135
happyReduction_135 (HappyAbsSyn60  happy_var_3)
	(HappyAbsSyn74  happy_var_2)
	_
	 =  HappyAbsSyn63
		 (YIf happy_var_2 happy_var_3
	)
happyReduction_135 _ _ _  = notHappyAtAll 

happyReduce_136 = happySpecReduce_3  70 happyReduction_136
happyReduction_136 (HappyAbsSyn71  happy_var_3)
	(HappyAbsSyn58  happy_var_2)
	_
	 =  HappyAbsSyn63
		 (YLet happy_var_2 happy_var_3
	)
happyReduction_136 _ _ _  = notHappyAtAll 

happyReduce_137 = happySpecReduce_2  71 happyReduction_137
happyReduction_137 (HappyAbsSyn74  happy_var_2)
	_
	 =  HappyAbsSyn71
		 (Just happy_var_2
	)
happyReduction_137 _ _  = notHappyAtAll 

happyReduce_138 = happySpecReduce_0  71 happyReduction_138
happyReduction_138  =  HappyAbsSyn71
		 (Nothing
	)

happyReduce_139 = happySpecReduce_3  72 happyReduction_139
happyReduction_139 (HappyAbsSyn74  happy_var_3)
	_
	(HappyAbsSyn58  happy_var_1)
	 =  HappyAbsSyn63
		 (YAssign happy_var_1 happy_var_3
	)
happyReduction_139 _ _ _  = notHappyAtAll 

happyReduce_140 = happySpecReduce_1  73 happyReduction_140
happyReduction_140 (HappyAbsSyn57  happy_var_1)
	 =  HappyAbsSyn58
		 ([happy_var_1]
	)
happyReduction_140 _  = notHappyAtAll 

happyReduce_141 = happySpecReduce_3  73 happyReduction_141
happyReduction_141 (HappyAbsSyn58  happy_var_3)
	_
	(HappyAbsSyn57  happy_var_1)
	 =  HappyAbsSyn58
		 (happy_var_1 : happy_var_3
	)
happyReduction_141 _ _ _  = notHappyAtAll 

happyReduce_142 = happySpecReduce_1  74 happyReduction_142
happyReduction_142 (HappyAbsSyn77  happy_var_1)
	 =  HappyAbsSyn74
		 (YLit happy_var_1
	)
happyReduction_142 _  = notHappyAtAll 

happyReduce_143 = happySpecReduce_1  74 happyReduction_143
happyReduction_143 (HappyAbsSyn57  happy_var_1)
	 =  HappyAbsSyn74
		 (YIdent happy_var_1
	)
happyReduction_143 _  = notHappyAtAll 

happyReduce_144 = happySpecReduce_2  74 happyReduction_144
happyReduction_144 (HappyAbsSyn75  happy_var_2)
	(HappyAbsSyn57  happy_var_1)
	 =  HappyAbsSyn74
		 (YCall happy_var_1 happy_var_2
	)
happyReduction_144 _ _  = notHappyAtAll 

happyReduce_145 = happySpecReduce_3  75 happyReduction_145
happyReduction_145 _
	(HappyAbsSyn75  happy_var_2)
	_
	 =  HappyAbsSyn75
		 (happy_var_2
	)
happyReduction_145 _ _ _  = notHappyAtAll 

happyReduce_146 = happySpecReduce_1  76 happyReduction_146
happyReduction_146 (HappyAbsSyn74  happy_var_1)
	 =  HappyAbsSyn75
		 ([happy_var_1]
	)
happyReduction_146 _  = notHappyAtAll 

happyReduce_147 = happySpecReduce_0  76 happyReduction_147
happyReduction_147  =  HappyAbsSyn75
		 ([]
	)

happyReduce_148 = happySpecReduce_3  76 happyReduction_148
happyReduction_148 (HappyAbsSyn75  happy_var_3)
	_
	(HappyAbsSyn74  happy_var_1)
	 =  HappyAbsSyn75
		 (happy_var_1 : happy_var_3
	)
happyReduction_148 _ _ _  = notHappyAtAll 

happyReduce_149 = happySpecReduce_1  77 happyReduction_149
happyReduction_149 (HappyTerminal (Token _ (TNumber happy_var_1)))
	 =  HappyAbsSyn77
		 (YulNumber $ toInteger happy_var_1
	)
happyReduction_149 _  = notHappyAtAll 

happyReduce_150 = happySpecReduce_1  77 happyReduction_150
happyReduction_150 (HappyTerminal (Token _ (TString happy_var_1)))
	 =  HappyAbsSyn77
		 (YulString happy_var_1
	)
happyReduction_150 _  = notHappyAtAll 

happyReduce_151 = happySpecReduce_1  78 happyReduction_151
happyReduction_151 _
	 =  HappyAbsSyn78
		 (()
	)

happyReduce_152 = happySpecReduce_0  78 happyReduction_152
happyReduction_152  =  HappyAbsSyn78
		 (()
	)

happyNewToken action sts stk
	= lexer(\tk -> 
	let cont i = action i i tk (HappyState action) sts stk in
	case tk of {
	Token _ TEOF -> action 120 120 tk (HappyState action) sts stk;
	Token _ (TIdent happy_dollar_dollar) -> cont 79;
	Token _ (TNumber happy_dollar_dollar) -> cont 80;
	Token _ (TTycon happy_dollar_dollar) -> cont 81;
	Token _ (TString happy_dollar_dollar) -> cont 82;
	Token _ TContract -> cont 83;
	Token _ TImport -> cont 84;
	Token _ TLet -> cont 85;
	Token _ TEq -> cont 86;
	Token _ TDot -> cont 87;
	Token _ TClass -> cont 88;
	Token _ TInstance -> cont 89;
	Token _ TIf -> cont 90;
	Token _ TFor -> cont 91;
	Token _ TSwitch -> cont 92;
	Token _ TCase -> cont 93;
	Token _ TDefault -> cont 94;
	Token _ TLeave -> cont 95;
	Token _ TContinue -> cont 96;
	Token _ TBreak -> cont 97;
	Token _ TAssembly -> cont 98;
	Token _ TData -> cont 99;
	Token _ TMatch -> cont 100;
	Token _ TFunction -> cont 101;
	Token _ TConstructor -> cont 102;
	Token _ TReturn -> cont 103;
	Token _ TLam -> cont 104;
	Token _ TType -> cont 105;
	Token _ TSemi -> cont 106;
	Token _ TYAssign -> cont 107;
	Token _ TColon -> cont 108;
	Token _ TComma -> cont 109;
	Token _ TArrow -> cont 110;
	Token _ TWildCard -> cont 111;
	Token _ TDArrow -> cont 112;
	Token _ TLParen -> cont 113;
	Token _ TRParen -> cont 114;
	Token _ TLBrace -> cont 115;
	Token _ TRBrace -> cont 116;
	Token _ TLBrack -> cont 117;
	Token _ TRBrack -> cont 118;
	Token _ TBar -> cont 119;
	_ -> happyError' (tk, [])
	})

happyError_ explist 120 tk = happyError' (tk, explist)
happyError_ explist _ tk = happyError' (tk, explist)

happyThen :: () => Alex a -> (a -> Alex b) -> Alex b
happyThen = ((>>=))
happyReturn :: () => a -> Alex a
happyReturn = (return)
happyThen1 :: () => Alex a -> (a -> Alex b) -> Alex b
happyThen1 = happyThen
happyReturn1 :: () => a -> Alex a
happyReturn1 = happyReturn
happyError' :: () => ((Token), [Prelude.String]) -> Alex a
happyError' tk = (\(tokens, _) -> parseError tokens) tk
parser = happySomeParser where
 happySomeParser = happyThen (happyParse action_0) (\x -> case x of {HappyAbsSyn4 z -> happyReturn z; _other -> notHappyAtAll })

happySeq = happyDontSeq


parseError :: Token -> Alex a
parseError _ 
  = do 
        (AlexPn _ line column, _, _, _) <- alexGetInput
        alexError $ "Parse error at line " ++ show line ++ 
                    ", column " ++ show column

lexer :: (Token -> Alex a) -> Alex a 
lexer = (=<< alexMonadScan)
{-# LINE 1 "templates/GenericTemplate.hs" #-}
-- $Id: GenericTemplate.hs,v 1.26 2005/01/14 14:47:22 simonmar Exp $










































data Happy_IntList = HappyCons Prelude.Int Happy_IntList








































infixr 9 `HappyStk`
data HappyStk a = HappyStk a (HappyStk a)

-----------------------------------------------------------------------------
-- starting the parse

happyParse start_state = happyNewToken start_state notHappyAtAll notHappyAtAll

-----------------------------------------------------------------------------
-- Accepting the parse

-- If the current token is ERROR_TOK, it means we've just accepted a partial
-- parse (a %partial parser).  We must ignore the saved token on the top of
-- the stack in this case.
happyAccept (1) tk st sts (_ `HappyStk` ans `HappyStk` _) =
        happyReturn1 ans
happyAccept j tk st sts (HappyStk ans _) = 
         (happyReturn1 ans)

-----------------------------------------------------------------------------
-- Arrays only: do the next action









































indexShortOffAddr arr off = arr Happy_Data_Array.! off


{-# INLINE happyLt #-}
happyLt x y = (x Prelude.< y)






readArrayBit arr bit =
    Bits.testBit (indexShortOffAddr arr (bit `Prelude.div` 16)) (bit `Prelude.mod` 16)






-----------------------------------------------------------------------------
-- HappyState data type (not arrays)



newtype HappyState b c = HappyState
        (Prelude.Int ->                    -- token number
         Prelude.Int ->                    -- token number (yes, again)
         b ->                           -- token semantic value
         HappyState b c ->              -- current state
         [HappyState b c] ->            -- state stack
         c)



-----------------------------------------------------------------------------
-- Shifting a token

happyShift new_state (1) tk st sts stk@(x `HappyStk` _) =
     let i = (case x of { HappyErrorToken (i) -> i }) in
--     trace "shifting the error token" $
     new_state i i tk (HappyState (new_state)) ((st):(sts)) (stk)

happyShift new_state i tk st sts stk =
     happyNewToken new_state ((st):(sts)) ((HappyTerminal (tk))`HappyStk`stk)

-- happyReduce is specialised for the common cases.

happySpecReduce_0 i fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happySpecReduce_0 nt fn j tk st@((HappyState (action))) sts stk
     = action nt j tk st ((st):(sts)) (fn `HappyStk` stk)

happySpecReduce_1 i fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happySpecReduce_1 nt fn j tk _ sts@(((st@(HappyState (action))):(_))) (v1`HappyStk`stk')
     = let r = fn v1 in
       happySeq r (action nt j tk st sts (r `HappyStk` stk'))

happySpecReduce_2 i fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happySpecReduce_2 nt fn j tk _ ((_):(sts@(((st@(HappyState (action))):(_))))) (v1`HappyStk`v2`HappyStk`stk')
     = let r = fn v1 v2 in
       happySeq r (action nt j tk st sts (r `HappyStk` stk'))

happySpecReduce_3 i fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happySpecReduce_3 nt fn j tk _ ((_):(((_):(sts@(((st@(HappyState (action))):(_))))))) (v1`HappyStk`v2`HappyStk`v3`HappyStk`stk')
     = let r = fn v1 v2 v3 in
       happySeq r (action nt j tk st sts (r `HappyStk` stk'))

happyReduce k i fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happyReduce k nt fn j tk st sts stk
     = case happyDrop (k Prelude.- ((1) :: Prelude.Int)) sts of
         sts1@(((st1@(HappyState (action))):(_))) ->
                let r = fn stk in  -- it doesn't hurt to always seq here...
                happyDoSeq r (action nt j tk st1 sts1 r)

happyMonadReduce k nt fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happyMonadReduce k nt fn j tk st sts stk =
      case happyDrop k ((st):(sts)) of
        sts1@(((st1@(HappyState (action))):(_))) ->
          let drop_stk = happyDropStk k stk in
          happyThen1 (fn stk tk) (\r -> action nt j tk st1 sts1 (r `HappyStk` drop_stk))

happyMonad2Reduce k nt fn (1) tk st sts stk
     = happyFail [] (1) tk st sts stk
happyMonad2Reduce k nt fn j tk st sts stk =
      case happyDrop k ((st):(sts)) of
        sts1@(((st1@(HappyState (action))):(_))) ->
         let drop_stk = happyDropStk k stk





             _ = nt :: Prelude.Int
             new_state = action

          in
          happyThen1 (fn stk tk) (\r -> happyNewToken new_state sts1 (r `HappyStk` drop_stk))

happyDrop (0) l = l
happyDrop n ((_):(t)) = happyDrop (n Prelude.- ((1) :: Prelude.Int)) t

happyDropStk (0) l = l
happyDropStk n (x `HappyStk` xs) = happyDropStk (n Prelude.- ((1)::Prelude.Int)) xs

-----------------------------------------------------------------------------
-- Moving to a new state after a reduction









happyGoto action j tk st = action j j tk (HappyState action)


-----------------------------------------------------------------------------
-- Error recovery (ERROR_TOK is the error token)

-- parse error if we are in recovery and we fail again
happyFail explist (1) tk old_st _ stk@(x `HappyStk` _) =
     let i = (case x of { HappyErrorToken (i) -> i }) in
--      trace "failing" $ 
        happyError_ explist i tk

{-  We don't need state discarding for our restricted implementation of
    "error".  In fact, it can cause some bogus parses, so I've disabled it
    for now --SDM

-- discard a state
happyFail  ERROR_TOK tk old_st CONS(HAPPYSTATE(action),sts) 
                                                (saved_tok `HappyStk` _ `HappyStk` stk) =
--      trace ("discarding state, depth " ++ show (length stk))  $
        DO_ACTION(action,ERROR_TOK,tk,sts,(saved_tok`HappyStk`stk))
-}

-- Enter error recovery: generate an error token,
--                       save the old token and carry on.
happyFail explist i tk (HappyState (action)) sts stk =
--      trace "entering error recovery" $
        action (1) (1) tk (HappyState (action)) sts ((HappyErrorToken (i)) `HappyStk` stk)

-- Internal happy errors:

notHappyAtAll :: a
notHappyAtAll = Prelude.error "Internal Happy error\n"

-----------------------------------------------------------------------------
-- Hack to get the typechecker to accept our action functions







-----------------------------------------------------------------------------
-- Seq-ing.  If the --strict flag is given, then Happy emits 
--      happySeq = happyDoSeq
-- otherwise it emits
--      happySeq = happyDontSeq

happyDoSeq, happyDontSeq :: a -> b -> b
happyDoSeq   a b = a `Prelude.seq` b
happyDontSeq a b = b

-----------------------------------------------------------------------------
-- Don't inline any functions from the template.  GHC has a nasty habit
-- of deciding to inline happyGoto everywhere, which increases the size of
-- the generated parser quite a bit.









{-# NOINLINE happyShift #-}
{-# NOINLINE happySpecReduce_0 #-}
{-# NOINLINE happySpecReduce_1 #-}
{-# NOINLINE happySpecReduce_2 #-}
{-# NOINLINE happySpecReduce_3 #-}
{-# NOINLINE happyReduce #-}
{-# NOINLINE happyMonadReduce #-}
{-# NOINLINE happyGoto #-}
{-# NOINLINE happyFail #-}

-- end of Happy Template.
