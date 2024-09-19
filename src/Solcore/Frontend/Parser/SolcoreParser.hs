{-# OPTIONS_GHC -w #-}
module Solcore.Frontend.Parser.SolcoreParser where

import Data.List.NonEmpty 

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
	| HappyAbsSyn9 (Pragma)
	| HappyAbsSyn10 (PragmaStatus)
	| HappyAbsSyn11 (NonEmpty Name)
	| HappyAbsSyn12 (Contract Name)
	| HappyAbsSyn13 ([ContractDecl Name])
	| HappyAbsSyn14 (ContractDecl Name)
	| HappyAbsSyn15 (TySym)
	| HappyAbsSyn16 (Field Name)
	| HappyAbsSyn17 (DataTy)
	| HappyAbsSyn18 ([Constr])
	| HappyAbsSyn19 (Constr)
	| HappyAbsSyn20 (Class Name)
	| HappyAbsSyn21 ([Signature Name])
	| HappyAbsSyn22 ([Tyvar])
	| HappyAbsSyn24 ([Pred])
	| HappyAbsSyn27 (Pred)
	| HappyAbsSyn29 (Signature Name)
	| HappyAbsSyn30 ([Param Name])
	| HappyAbsSyn31 (Param Name)
	| HappyAbsSyn32 (Instance Name)
	| HappyAbsSyn33 ([Ty])
	| HappyAbsSyn35 ([FunDef Name])
	| HappyAbsSyn37 (FunDef Name)
	| HappyAbsSyn38 (Maybe Ty)
	| HappyAbsSyn39 (Constructor Name)
	| HappyAbsSyn40 ([Stmt Name])
	| HappyAbsSyn42 (Stmt Name)
	| HappyAbsSyn43 ([Exp Name])
	| HappyAbsSyn44 (Maybe (Exp Name))
	| HappyAbsSyn45 (Exp Name)
	| HappyAbsSyn49 ([([Pat Name], [Stmt Name])])
	| HappyAbsSyn50 (([Pat Name], [Stmt Name]))
	| HappyAbsSyn51 ([Pat Name])
	| HappyAbsSyn52 (Pat Name)
	| HappyAbsSyn55 (Literal)
	| HappyAbsSyn56 (Ty)
	| HappyAbsSyn57 (([Ty], Ty))
	| HappyAbsSyn58 (Tyvar)
	| HappyAbsSyn59 (Name)
	| HappyAbsSyn60 ([Name])
	| HappyAbsSyn62 (YulBlock)
	| HappyAbsSyn64 ([YulStmt])
	| HappyAbsSyn65 (YulStmt)
	| HappyAbsSyn68 (YulCases)
	| HappyAbsSyn69 ((YLiteral, YulBlock))
	| HappyAbsSyn70 (Maybe YulBlock)
	| HappyAbsSyn73 (Maybe YulExp)
	| HappyAbsSyn76 (YulExp)
	| HappyAbsSyn77 ([YulExp])
	| HappyAbsSyn79 (YLiteral)
	| HappyAbsSyn80 (())

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
 action_276,
 action_277,
 action_278,
 action_279,
 action_280,
 action_281,
 action_282,
 action_283,
 action_284,
 action_285,
 action_286,
 action_287,
 action_288,
 action_289,
 action_290,
 action_291,
 action_292,
 action_293,
 action_294,
 action_295,
 action_296,
 action_297,
 action_298,
 action_299 :: () => Prelude.Int -> ({-HappyReduction (Alex) = -}
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
 happyReduce_152,
 happyReduce_153,
 happyReduce_154,
 happyReduce_155,
 happyReduce_156,
 happyReduce_157,
 happyReduce_158,
 happyReduce_159 :: () => ({-HappyReduction (Alex) = -}
	   Prelude.Int 
	-> (Token)
	-> HappyState (Token) (HappyStk HappyAbsSyn -> (Alex) HappyAbsSyn)
	-> [HappyState (Token) (HappyStk HappyAbsSyn -> (Alex) HappyAbsSyn)] 
	-> HappyStk HappyAbsSyn 
	-> (Alex) HappyAbsSyn)

happyExpList :: Happy_Data_Array.Array Prelude.Int Prelude.Int
happyExpList = Happy_Data_Array.listArray (0,629) ([0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,49152,32824,546,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,900,8744,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,32,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,32,0,0,0,0,0,0,0,4,0,0,0,0,0,0,8192,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,16384,0,0,0,0,0,64,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,896,0,0,0,0,0,1024,0,0,0,0,0,0,0,128,0,0,0,0,0,0,0,16,0,0,0,0,0,0,0,0,0,64,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1024,0,0,0,0,0,5,0,128,0,0,0,0,0,0,0,0,0,0,0,0,5120,0,0,2,0,0,0,0,128,0,0,0,0,0,0,0,4096,0,0,0,0,0,0,0,0,0,16,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,256,0,0,0,0,0,0,0,4096,0,0,0,0,0,0,0,0,0,0,0,0,32768,39,808,64,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,64,0,0,0,0,0,3072,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16384,0,0,0,0,0,0,0,0,0,0,16,0,0,0,0,3840,0,32772,0,0,0,0,0,480,32768,4096,0,0,0,0,0,0,0,512,0,0,0,0,32768,7,512,64,0,0,0,0,0,0,0,32,0,0,0,0,512,0,0,0,0,0,0,0,256,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,16,0,0,0,0,0,0,4096,0,0,0,0,0,0,0,32768,0,0,0,0,0,0,0,128,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,32768,0,0,0,0,0,160,0,4096,0,0,0,0,0,0,0,16,0,0,0,0,0,64,0,0,0,0,0,0,4096,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,64,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,8192,0,0,0,0,0,0,0,1024,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,10240,0,0,4,0,0,0,0,0,0,0,1,0,0,0,0,0,0,256,0,0,0,0,0,0,0,16,0,0,0,0,0,2,0,0,0,0,0,0,16384,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,512,0,0,0,0,0,0,0,0,0,0,0,0,0,5,0,128,0,0,0,0,32768,0,0,0,0,0,0,0,5120,0,0,2,0,0,0,0,0,0,8192,0,0,0,0,0,64,0,0,0,0,0,0,0,0,256,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,16416,13312,1,0,0,0,0,0,1024,0,1024,0,0,0,0,32768,0,0,0,0,0,0,0,0,16,0,0,0,0,0,0,0,0,0,4,0,0,0,0,16384,0,512,0,0,0,0,0,0,0,0,0,0,0,0,0,28747,14,512,0,0,0,0,0,16,32768,0,0,0,0,0,0,0,0,0,0,0,0,0,1920,0,16386,0,0,0,0,0,0,0,0,0,0,0,0,0,30,2048,256,0,0,0,0,49152,3,256,32,0,0,0,0,2048,0,0,0,0,0,0,0,20224,20480,32774,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,64,0,0,0,0,0,16,0,0,0,0,0,0,0,2,4096,0,0,0,0,0,0,0,16384,0,0,0,0,0,0,0,2048,0,0,0,0,0,0,0,0,0,0,0,0,57344,1,128,16,0,0,0,0,5120,0,0,2,0,0,0,0,0,0,17408,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2048,0,0,0,0,0,0,16384,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8192,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8192,0,0,0,0,0,0,0,11264,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,176,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3840,0,32772,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,1024,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,64,0,0,0,0,512,16388,19,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,512,0,0,0,0,0,0,0,2048,0,0,0,0,0,0,0,0,0,0,0,0,16384,0,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,512,0,0,0,0,0,0,0,128,0,0,0,0,20480,0,0,8,0,0,0,0,0,0,8192,0,0,0,0,0,0,0,8192,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2048,0,0,0,0,0,0,0,16,0,0,0,0,5120,0,0,2,0,0,0,0,128,0,0,0,0,0,0,0,0,0,256,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1280,0,32768,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16384,0,0,0,0,0,0,0,0,0,0,4,0,0,0,0,320,0,8192,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,16384,0,0,0,0,0,16,0,0,0,0,0,0,0,10,0,256,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4096,0,0,0,0,0,0,0,32768,0,0,0,0,0,0,0,8192,0,0,0,0,32768,7,0,80,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,32,0,0,0,0,0,0,88,0,0,0,0,0,0,0,0,0,512,0,0,0,0,0,0,0,1,0,0,0,0,0,0,2048,0,0,0,0,0,1408,0,0,0,0,0,0,0,1200,231,8192,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,256,0,0,0,0,0,0,0,352,0,0,0,0,0,0,0,512,0,0,0,0,0,0,0,128,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,960,0,8193,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8192,0,0,0,0,0,0,0,32768,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2816,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2048,0,0,0,0,0,32768,0,0,0,0,0,0,0,2048,0,0,0,0,0,0,5120,0,0,0,0,0,0,0,0,0,4096,0,0,0,0,0,0,0,64,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,240,0,2560,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16,0,0,0,0,32768,0,0,0,0,0,0,0,0,0,8192,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,32,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4096,1024,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16,0,0,0,0,0,16385,0,0,0,0,0,0,0,0,16384,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,64,0,0,0,0,0,0,0,16,0,0,0,0,0,0,256,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1024,0,0,0,0,0,0,0,0,0,0,0,0,61440,0,0,10,0,0,0,0,7680,0,16384,1,0,0,0,0,5056,37888,8193,0,0,0,0,0,0,0,4096,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,49152,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4096,0,0,0,0,0,0,0,16384,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16384,0,0,0,0,0,0,16385,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,60,0,640,0,0,0,0,0,0,0,0,0
	])

{-# NOINLINE happyExpListPerState #-}
happyExpListPerState st =
    token_strs_expected
  where token_strs = ["error","%dummy","%start_parser","CompilationUnit","ImportList","Import","TopDeclList","TopDecl","Pragma","Status","NameList","Contract","DeclList","Decl","TypeSynonym","FieldDef","DataDef","Constrs","Constr","ClassDef","ClassBody","OptParam","VarCommaList","ContextOpt","Context","ConstraintList","Constraint","Signatures","Signature","ParamList","Param","InstDef","OptTypeParam","TypeCommaList","Functions","InstBody","Function","OptRetTy","Constructor","Body","StmtList","Stmt","MatchArgList","InitOpt","Expr","ConArgs","FunArgs","ExprCommaList","Equations","Equation","PatCommaList","Pattern","PatternList","PatList","Literal","Type","LamType","Var","Con","QualName","Name","AsmBlock","YulBlock","YulStmts","YulStmt","YulFor","YulSwitch","YulCases","YulCase","YulDefault","YulIf","YulVarDecl","YulOptAss","YulAssignment","IdentifierList","YulExp","YulFunArgs","YulExpCommaList","YulLiteral","OptSemi","identifier","number","tycon","stringlit","'contract'","'import'","'let'","'='","'.'","'forall'","'class'","'instance'","'if'","'for'","'switch'","'case'","'default'","'leave'","'continue'","'break'","'assembly'","'data'","'match'","'function'","'constructor'","'return'","'lam'","'type'","'no-patterson-condition'","'no-coverage-condition'","'no-bounded-variable-condition'","'pragma'","';'","':='","':'","','","'->'","'_'","'=>'","'('","')'","'{'","'}'","'|'","%eof"]
        bit_start = st Prelude.* 125
        bit_end = (st Prelude.+ 1) Prelude.* 125
        read_bit = readArrayBit happyExpList
        bits = Prelude.map read_bit [bit_start..bit_end Prelude.- 1]
        bits_indexed = Prelude.zip bits [0..124]
        token_strs_expected = Prelude.concatMap f bits_indexed
        f (Prelude.False, _) = []
        f (Prelude.True, nr) = [token_strs Prelude.!! nr]

action_0 (4) = happyGoto action_3
action_0 (5) = happyGoto action_2
action_0 _ = happyReduce_3

action_1 (5) = happyGoto action_2
action_1 _ = happyFail (happyExpListPerState 1)

action_2 (85) = happyShift action_15
action_2 (86) = happyShift action_16
action_2 (90) = happyShift action_17
action_2 (91) = happyShift action_18
action_2 (92) = happyShift action_19
action_2 (102) = happyShift action_20
action_2 (104) = happyShift action_21
action_2 (108) = happyShift action_22
action_2 (112) = happyShift action_23
action_2 (6) = happyGoto action_4
action_2 (7) = happyGoto action_5
action_2 (8) = happyGoto action_6
action_2 (9) = happyGoto action_7
action_2 (12) = happyGoto action_8
action_2 (15) = happyGoto action_9
action_2 (17) = happyGoto action_10
action_2 (20) = happyGoto action_11
action_2 (29) = happyGoto action_12
action_2 (32) = happyGoto action_13
action_2 (37) = happyGoto action_14
action_2 _ = happyReduce_6

action_3 (125) = happyAccept
action_3 _ = happyFail (happyExpListPerState 3)

action_4 _ = happyReduce_2

action_5 _ = happyReduce_1

action_6 (85) = happyShift action_15
action_6 (90) = happyShift action_17
action_6 (91) = happyShift action_18
action_6 (92) = happyShift action_19
action_6 (102) = happyShift action_20
action_6 (104) = happyShift action_21
action_6 (108) = happyShift action_22
action_6 (112) = happyShift action_23
action_6 (7) = happyGoto action_44
action_6 (8) = happyGoto action_6
action_6 (9) = happyGoto action_7
action_6 (12) = happyGoto action_8
action_6 (15) = happyGoto action_9
action_6 (17) = happyGoto action_10
action_6 (20) = happyGoto action_11
action_6 (29) = happyGoto action_12
action_6 (32) = happyGoto action_13
action_6 (37) = happyGoto action_14
action_6 _ = happyReduce_6

action_7 _ = happyReduce_13

action_8 _ = happyReduce_7

action_9 _ = happyReduce_12

action_10 _ = happyReduce_11

action_11 _ = happyReduce_9

action_12 (122) = happyShift action_43
action_12 (40) = happyGoto action_42
action_12 _ = happyFail (happyExpListPerState 12)

action_13 _ = happyReduce_10

action_14 _ = happyReduce_8

action_15 (83) = happyShift action_28
action_15 (59) = happyGoto action_41
action_15 _ = happyFail (happyExpListPerState 15)

action_16 (83) = happyShift action_28
action_16 (59) = happyGoto action_39
action_16 (60) = happyGoto action_40
action_16 _ = happyFail (happyExpListPerState 16)

action_17 (81) = happyShift action_30
action_17 (23) = happyGoto action_36
action_17 (58) = happyGoto action_37
action_17 (61) = happyGoto action_38
action_17 _ = happyFail (happyExpListPerState 17)

action_18 (81) = happyReduce_41
action_18 (120) = happyShift action_34
action_18 (24) = happyGoto action_35
action_18 (25) = happyGoto action_33
action_18 _ = happyReduce_41

action_19 (81) = happyReduce_41
action_19 (83) = happyReduce_41
action_19 (120) = happyShift action_34
action_19 (24) = happyGoto action_32
action_19 (25) = happyGoto action_33
action_19 _ = happyReduce_41

action_20 (83) = happyShift action_28
action_20 (59) = happyGoto action_31
action_20 _ = happyFail (happyExpListPerState 20)

action_21 (81) = happyShift action_30
action_21 (61) = happyGoto action_29
action_21 _ = happyFail (happyExpListPerState 21)

action_22 (83) = happyShift action_28
action_22 (59) = happyGoto action_27
action_22 _ = happyFail (happyExpListPerState 22)

action_23 (109) = happyShift action_24
action_23 (110) = happyShift action_25
action_23 (111) = happyShift action_26
action_23 _ = happyFail (happyExpListPerState 23)

action_24 (83) = happyShift action_28
action_24 (10) = happyGoto action_82
action_24 (11) = happyGoto action_79
action_24 (59) = happyGoto action_80
action_24 _ = happyReduce_18

action_25 (83) = happyShift action_28
action_25 (10) = happyGoto action_81
action_25 (11) = happyGoto action_79
action_25 (59) = happyGoto action_80
action_25 _ = happyReduce_18

action_26 (83) = happyShift action_28
action_26 (10) = happyGoto action_78
action_26 (11) = happyGoto action_79
action_26 (59) = happyGoto action_80
action_26 _ = happyReduce_18

action_27 (120) = happyShift action_61
action_27 (22) = happyGoto action_77
action_27 _ = happyReduce_38

action_28 _ = happyReduce_117

action_29 (120) = happyShift action_76
action_29 _ = happyFail (happyExpListPerState 29)

action_30 _ = happyReduce_120

action_31 (120) = happyShift action_61
action_31 (22) = happyGoto action_75
action_31 _ = happyReduce_38

action_32 (81) = happyShift action_30
action_32 (83) = happyShift action_28
action_32 (120) = happyShift action_73
action_32 (56) = happyGoto action_74
action_32 (57) = happyGoto action_70
action_32 (58) = happyGoto action_71
action_32 (59) = happyGoto action_72
action_32 (61) = happyGoto action_38
action_32 _ = happyFail (happyExpListPerState 32)

action_33 _ = happyReduce_42

action_34 (81) = happyShift action_30
action_34 (83) = happyShift action_28
action_34 (120) = happyShift action_73
action_34 (26) = happyGoto action_67
action_34 (27) = happyGoto action_68
action_34 (56) = happyGoto action_69
action_34 (57) = happyGoto action_70
action_34 (58) = happyGoto action_71
action_34 (59) = happyGoto action_72
action_34 (61) = happyGoto action_38
action_34 _ = happyFail (happyExpListPerState 34)

action_35 (81) = happyShift action_30
action_35 (58) = happyGoto action_66
action_35 (61) = happyGoto action_38
action_35 _ = happyFail (happyExpListPerState 35)

action_36 (89) = happyShift action_65
action_36 _ = happyFail (happyExpListPerState 36)

action_37 (116) = happyShift action_64
action_37 _ = happyReduce_40

action_38 _ = happyReduce_116

action_39 _ = happyReduce_118

action_40 (89) = happyShift action_62
action_40 (113) = happyShift action_63
action_40 _ = happyFail (happyExpListPerState 40)

action_41 (120) = happyShift action_61
action_41 (22) = happyGoto action_60
action_41 _ = happyReduce_38

action_42 _ = happyReduce_64

action_43 (81) = happyShift action_30
action_43 (82) = happyShift action_52
action_43 (83) = happyShift action_28
action_43 (84) = happyShift action_53
action_43 (87) = happyShift action_54
action_43 (101) = happyShift action_55
action_43 (103) = happyShift action_56
action_43 (106) = happyShift action_57
action_43 (107) = happyShift action_58
action_43 (120) = happyShift action_59
action_43 (41) = happyGoto action_45
action_43 (42) = happyGoto action_46
action_43 (45) = happyGoto action_47
action_43 (55) = happyGoto action_48
action_43 (59) = happyGoto action_49
action_43 (61) = happyGoto action_50
action_43 (62) = happyGoto action_51
action_43 _ = happyReduce_70

action_44 _ = happyReduce_5

action_45 (123) = happyShift action_121
action_45 _ = happyFail (happyExpListPerState 45)

action_46 (113) = happyShift action_120
action_46 _ = happyFail (happyExpListPerState 46)

action_47 (88) = happyShift action_118
action_47 (89) = happyShift action_119
action_47 _ = happyReduce_74

action_48 _ = happyReduce_84

action_49 (120) = happyShift action_117
action_49 (46) = happyGoto action_116
action_49 _ = happyReduce_91

action_50 (120) = happyShift action_115
action_50 (47) = happyGoto action_114
action_50 _ = happyReduce_82

action_51 _ = happyReduce_77

action_52 _ = happyReduce_110

action_53 _ = happyReduce_111

action_54 (81) = happyShift action_30
action_54 (61) = happyGoto action_113
action_54 _ = happyFail (happyExpListPerState 54)

action_55 (122) = happyShift action_112
action_55 (63) = happyGoto action_111
action_55 _ = happyFail (happyExpListPerState 55)

action_56 (81) = happyShift action_30
action_56 (82) = happyShift action_52
action_56 (83) = happyShift action_28
action_56 (84) = happyShift action_53
action_56 (107) = happyShift action_58
action_56 (120) = happyShift action_59
action_56 (43) = happyGoto action_109
action_56 (45) = happyGoto action_110
action_56 (55) = happyGoto action_48
action_56 (59) = happyGoto action_49
action_56 (61) = happyGoto action_50
action_56 _ = happyFail (happyExpListPerState 56)

action_57 (81) = happyShift action_30
action_57 (82) = happyShift action_52
action_57 (83) = happyShift action_28
action_57 (84) = happyShift action_53
action_57 (107) = happyShift action_58
action_57 (120) = happyShift action_59
action_57 (45) = happyGoto action_108
action_57 (55) = happyGoto action_48
action_57 (59) = happyGoto action_49
action_57 (61) = happyGoto action_50
action_57 _ = happyFail (happyExpListPerState 57)

action_58 (120) = happyShift action_107
action_58 _ = happyFail (happyExpListPerState 58)

action_59 (81) = happyShift action_30
action_59 (82) = happyShift action_52
action_59 (83) = happyShift action_28
action_59 (84) = happyShift action_53
action_59 (107) = happyShift action_58
action_59 (120) = happyShift action_59
action_59 (45) = happyGoto action_106
action_59 (55) = happyGoto action_48
action_59 (59) = happyGoto action_49
action_59 (61) = happyGoto action_50
action_59 _ = happyFail (happyExpListPerState 59)

action_60 (122) = happyShift action_105
action_60 _ = happyFail (happyExpListPerState 60)

action_61 (81) = happyShift action_30
action_61 (23) = happyGoto action_104
action_61 (58) = happyGoto action_37
action_61 (61) = happyGoto action_38
action_61 _ = happyFail (happyExpListPerState 61)

action_62 (83) = happyShift action_28
action_62 (59) = happyGoto action_103
action_62 _ = happyFail (happyExpListPerState 62)

action_63 _ = happyReduce_4

action_64 (81) = happyShift action_30
action_64 (23) = happyGoto action_102
action_64 (58) = happyGoto action_37
action_64 (61) = happyGoto action_38
action_64 _ = happyFail (happyExpListPerState 64)

action_65 (120) = happyShift action_34
action_65 (25) = happyGoto action_101
action_65 _ = happyFail (happyExpListPerState 65)

action_66 (115) = happyShift action_100
action_66 _ = happyFail (happyExpListPerState 66)

action_67 (121) = happyShift action_99
action_67 _ = happyFail (happyExpListPerState 67)

action_68 (116) = happyShift action_98
action_68 _ = happyReduce_45

action_69 (115) = happyShift action_97
action_69 _ = happyFail (happyExpListPerState 69)

action_70 _ = happyReduce_114

action_71 _ = happyReduce_113

action_72 (120) = happyShift action_96
action_72 (33) = happyGoto action_95
action_72 _ = happyReduce_58

action_73 (81) = happyShift action_30
action_73 (83) = happyShift action_28
action_73 (120) = happyShift action_73
action_73 (34) = happyGoto action_93
action_73 (56) = happyGoto action_94
action_73 (57) = happyGoto action_70
action_73 (58) = happyGoto action_71
action_73 (59) = happyGoto action_72
action_73 (61) = happyGoto action_38
action_73 _ = happyFail (happyExpListPerState 73)

action_74 (115) = happyShift action_92
action_74 _ = happyFail (happyExpListPerState 74)

action_75 (88) = happyShift action_91
action_75 _ = happyFail (happyExpListPerState 75)

action_76 (81) = happyShift action_30
action_76 (30) = happyGoto action_88
action_76 (31) = happyGoto action_89
action_76 (61) = happyGoto action_90
action_76 _ = happyReduce_53

action_77 (88) = happyShift action_87
action_77 _ = happyFail (happyExpListPerState 77)

action_78 (113) = happyShift action_86
action_78 _ = happyFail (happyExpListPerState 78)

action_79 _ = happyReduce_17

action_80 (116) = happyShift action_85
action_80 _ = happyReduce_20

action_81 (113) = happyShift action_84
action_81 _ = happyFail (happyExpListPerState 81)

action_82 (113) = happyShift action_83
action_82 _ = happyFail (happyExpListPerState 82)

action_83 _ = happyReduce_15

action_84 _ = happyReduce_14

action_85 (83) = happyShift action_28
action_85 (11) = happyGoto action_182
action_85 (59) = happyGoto action_80
action_85 _ = happyFail (happyExpListPerState 85)

action_86 _ = happyReduce_16

action_87 (81) = happyShift action_30
action_87 (83) = happyShift action_28
action_87 (120) = happyShift action_73
action_87 (56) = happyGoto action_181
action_87 (57) = happyGoto action_70
action_87 (58) = happyGoto action_71
action_87 (59) = happyGoto action_72
action_87 (61) = happyGoto action_38
action_87 _ = happyFail (happyExpListPerState 87)

action_88 (121) = happyShift action_180
action_88 _ = happyFail (happyExpListPerState 88)

action_89 (116) = happyShift action_179
action_89 _ = happyReduce_51

action_90 (115) = happyShift action_178
action_90 _ = happyReduce_55

action_91 (83) = happyShift action_28
action_91 (18) = happyGoto action_175
action_91 (19) = happyGoto action_176
action_91 (59) = happyGoto action_177
action_91 _ = happyFail (happyExpListPerState 91)

action_92 (83) = happyShift action_28
action_92 (59) = happyGoto action_174
action_92 _ = happyFail (happyExpListPerState 92)

action_93 (121) = happyShift action_173
action_93 _ = happyFail (happyExpListPerState 93)

action_94 (116) = happyShift action_172
action_94 _ = happyReduce_60

action_95 _ = happyReduce_112

action_96 (81) = happyShift action_30
action_96 (83) = happyShift action_28
action_96 (120) = happyShift action_73
action_96 (34) = happyGoto action_171
action_96 (56) = happyGoto action_94
action_96 (57) = happyGoto action_70
action_96 (58) = happyGoto action_71
action_96 (59) = happyGoto action_72
action_96 (61) = happyGoto action_38
action_96 _ = happyFail (happyExpListPerState 96)

action_97 (83) = happyShift action_28
action_97 (59) = happyGoto action_170
action_97 _ = happyFail (happyExpListPerState 97)

action_98 (81) = happyShift action_30
action_98 (83) = happyShift action_28
action_98 (120) = happyShift action_73
action_98 (26) = happyGoto action_169
action_98 (27) = happyGoto action_68
action_98 (56) = happyGoto action_69
action_98 (57) = happyGoto action_70
action_98 (58) = happyGoto action_71
action_98 (59) = happyGoto action_72
action_98 (61) = happyGoto action_38
action_98 _ = happyFail (happyExpListPerState 98)

action_99 (119) = happyShift action_168
action_99 _ = happyFail (happyExpListPerState 99)

action_100 (83) = happyShift action_28
action_100 (59) = happyGoto action_167
action_100 _ = happyFail (happyExpListPerState 100)

action_101 (104) = happyShift action_166
action_101 _ = happyFail (happyExpListPerState 101)

action_102 _ = happyReduce_39

action_103 _ = happyReduce_119

action_104 (121) = happyShift action_165
action_104 _ = happyFail (happyExpListPerState 104)

action_105 (81) = happyShift action_30
action_105 (90) = happyShift action_17
action_105 (102) = happyShift action_20
action_105 (104) = happyShift action_21
action_105 (105) = happyShift action_164
action_105 (108) = happyShift action_22
action_105 (13) = happyGoto action_156
action_105 (14) = happyGoto action_157
action_105 (15) = happyGoto action_158
action_105 (16) = happyGoto action_159
action_105 (17) = happyGoto action_160
action_105 (29) = happyGoto action_12
action_105 (37) = happyGoto action_161
action_105 (39) = happyGoto action_162
action_105 (61) = happyGoto action_163
action_105 _ = happyReduce_23

action_106 (89) = happyShift action_119
action_106 (121) = happyShift action_155
action_106 _ = happyFail (happyExpListPerState 106)

action_107 (81) = happyShift action_30
action_107 (30) = happyGoto action_154
action_107 (31) = happyGoto action_89
action_107 (61) = happyGoto action_90
action_107 _ = happyReduce_53

action_108 (89) = happyShift action_119
action_108 _ = happyReduce_75

action_109 (122) = happyShift action_153
action_109 _ = happyFail (happyExpListPerState 109)

action_110 (89) = happyShift action_119
action_110 (116) = happyShift action_152
action_110 _ = happyReduce_78

action_111 _ = happyReduce_121

action_112 (81) = happyShift action_30
action_112 (82) = happyShift action_143
action_112 (84) = happyShift action_144
action_112 (87) = happyShift action_145
action_112 (93) = happyShift action_146
action_112 (94) = happyShift action_147
action_112 (95) = happyShift action_148
action_112 (98) = happyShift action_149
action_112 (99) = happyShift action_150
action_112 (100) = happyShift action_151
action_112 (122) = happyShift action_112
action_112 (61) = happyGoto action_131
action_112 (63) = happyGoto action_132
action_112 (64) = happyGoto action_133
action_112 (65) = happyGoto action_134
action_112 (66) = happyGoto action_135
action_112 (67) = happyGoto action_136
action_112 (71) = happyGoto action_137
action_112 (72) = happyGoto action_138
action_112 (74) = happyGoto action_139
action_112 (75) = happyGoto action_140
action_112 (76) = happyGoto action_141
action_112 (79) = happyGoto action_142
action_112 _ = happyReduce_124

action_113 (88) = happyShift action_129
action_113 (115) = happyShift action_130
action_113 (44) = happyGoto action_128
action_113 _ = happyReduce_80

action_114 _ = happyReduce_88

action_115 (81) = happyShift action_30
action_115 (82) = happyShift action_52
action_115 (83) = happyShift action_28
action_115 (84) = happyShift action_53
action_115 (107) = happyShift action_58
action_115 (120) = happyShift action_59
action_115 (45) = happyGoto action_125
action_115 (48) = happyGoto action_127
action_115 (55) = happyGoto action_48
action_115 (59) = happyGoto action_49
action_115 (61) = happyGoto action_50
action_115 _ = happyReduce_94

action_116 _ = happyReduce_83

action_117 (81) = happyShift action_30
action_117 (82) = happyShift action_52
action_117 (83) = happyShift action_28
action_117 (84) = happyShift action_53
action_117 (107) = happyShift action_58
action_117 (120) = happyShift action_59
action_117 (45) = happyGoto action_125
action_117 (48) = happyGoto action_126
action_117 (55) = happyGoto action_48
action_117 (59) = happyGoto action_49
action_117 (61) = happyGoto action_50
action_117 _ = happyReduce_94

action_118 (81) = happyShift action_30
action_118 (82) = happyShift action_52
action_118 (83) = happyShift action_28
action_118 (84) = happyShift action_53
action_118 (107) = happyShift action_58
action_118 (120) = happyShift action_59
action_118 (45) = happyGoto action_124
action_118 (55) = happyGoto action_48
action_118 (59) = happyGoto action_49
action_118 (61) = happyGoto action_50
action_118 _ = happyFail (happyExpListPerState 118)

action_119 (81) = happyShift action_30
action_119 (61) = happyGoto action_123
action_119 _ = happyFail (happyExpListPerState 119)

action_120 (81) = happyShift action_30
action_120 (82) = happyShift action_52
action_120 (83) = happyShift action_28
action_120 (84) = happyShift action_53
action_120 (87) = happyShift action_54
action_120 (101) = happyShift action_55
action_120 (103) = happyShift action_56
action_120 (106) = happyShift action_57
action_120 (107) = happyShift action_58
action_120 (120) = happyShift action_59
action_120 (41) = happyGoto action_122
action_120 (42) = happyGoto action_46
action_120 (45) = happyGoto action_47
action_120 (55) = happyGoto action_48
action_120 (59) = happyGoto action_49
action_120 (61) = happyGoto action_50
action_120 (62) = happyGoto action_51
action_120 _ = happyReduce_70

action_121 _ = happyReduce_68

action_122 _ = happyReduce_69

action_123 (120) = happyShift action_115
action_123 (47) = happyGoto action_223
action_123 _ = happyReduce_86

action_124 (89) = happyShift action_119
action_124 _ = happyReduce_71

action_125 (89) = happyShift action_119
action_125 (116) = happyShift action_222
action_125 _ = happyReduce_93

action_126 (121) = happyShift action_221
action_126 _ = happyFail (happyExpListPerState 126)

action_127 (121) = happyShift action_220
action_127 _ = happyFail (happyExpListPerState 127)

action_128 _ = happyReduce_73

action_129 (81) = happyShift action_30
action_129 (82) = happyShift action_52
action_129 (83) = happyShift action_28
action_129 (84) = happyShift action_53
action_129 (107) = happyShift action_58
action_129 (120) = happyShift action_59
action_129 (45) = happyGoto action_219
action_129 (55) = happyGoto action_48
action_129 (59) = happyGoto action_49
action_129 (61) = happyGoto action_50
action_129 _ = happyFail (happyExpListPerState 129)

action_130 (81) = happyShift action_30
action_130 (83) = happyShift action_28
action_130 (120) = happyShift action_73
action_130 (56) = happyGoto action_218
action_130 (57) = happyGoto action_70
action_130 (58) = happyGoto action_71
action_130 (59) = happyGoto action_72
action_130 (61) = happyGoto action_38
action_130 _ = happyFail (happyExpListPerState 130)

action_131 (114) = happyReduce_147
action_131 (116) = happyShift action_216
action_131 (120) = happyShift action_217
action_131 (77) = happyGoto action_215
action_131 _ = happyReduce_150

action_132 _ = happyReduce_126

action_133 (123) = happyShift action_214
action_133 _ = happyFail (happyExpListPerState 133)

action_134 (113) = happyShift action_213
action_134 (80) = happyGoto action_212
action_134 _ = happyReduce_159

action_135 _ = happyReduce_131

action_136 _ = happyReduce_130

action_137 _ = happyReduce_129

action_138 _ = happyReduce_127

action_139 _ = happyReduce_125

action_140 (114) = happyShift action_211
action_140 _ = happyFail (happyExpListPerState 140)

action_141 _ = happyReduce_128

action_142 _ = happyReduce_149

action_143 _ = happyReduce_156

action_144 _ = happyReduce_157

action_145 (81) = happyShift action_30
action_145 (61) = happyGoto action_209
action_145 (75) = happyGoto action_210
action_145 _ = happyFail (happyExpListPerState 145)

action_146 (81) = happyShift action_30
action_146 (82) = happyShift action_143
action_146 (84) = happyShift action_144
action_146 (61) = happyGoto action_205
action_146 (76) = happyGoto action_208
action_146 (79) = happyGoto action_142
action_146 _ = happyFail (happyExpListPerState 146)

action_147 (122) = happyShift action_112
action_147 (63) = happyGoto action_207
action_147 _ = happyFail (happyExpListPerState 147)

action_148 (81) = happyShift action_30
action_148 (82) = happyShift action_143
action_148 (84) = happyShift action_144
action_148 (61) = happyGoto action_205
action_148 (76) = happyGoto action_206
action_148 (79) = happyGoto action_142
action_148 _ = happyFail (happyExpListPerState 148)

action_149 _ = happyReduce_134

action_150 _ = happyReduce_132

action_151 _ = happyReduce_133

action_152 (81) = happyShift action_30
action_152 (82) = happyShift action_52
action_152 (83) = happyShift action_28
action_152 (84) = happyShift action_53
action_152 (107) = happyShift action_58
action_152 (120) = happyShift action_59
action_152 (43) = happyGoto action_204
action_152 (45) = happyGoto action_110
action_152 (55) = happyGoto action_48
action_152 (59) = happyGoto action_49
action_152 (61) = happyGoto action_50
action_152 _ = happyFail (happyExpListPerState 152)

action_153 (124) = happyShift action_203
action_153 (49) = happyGoto action_201
action_153 (50) = happyGoto action_202
action_153 _ = happyReduce_97

action_154 (121) = happyShift action_200
action_154 _ = happyFail (happyExpListPerState 154)

action_155 _ = happyReduce_85

action_156 (123) = happyShift action_199
action_156 _ = happyFail (happyExpListPerState 156)

action_157 (81) = happyShift action_30
action_157 (90) = happyShift action_17
action_157 (102) = happyShift action_20
action_157 (104) = happyShift action_21
action_157 (105) = happyShift action_164
action_157 (108) = happyShift action_22
action_157 (13) = happyGoto action_198
action_157 (14) = happyGoto action_157
action_157 (15) = happyGoto action_158
action_157 (16) = happyGoto action_159
action_157 (17) = happyGoto action_160
action_157 (29) = happyGoto action_12
action_157 (37) = happyGoto action_161
action_157 (39) = happyGoto action_162
action_157 (61) = happyGoto action_163
action_157 _ = happyReduce_23

action_158 _ = happyReduce_28

action_159 _ = happyReduce_24

action_160 _ = happyReduce_25

action_161 _ = happyReduce_26

action_162 _ = happyReduce_27

action_163 (115) = happyShift action_197
action_163 _ = happyFail (happyExpListPerState 163)

action_164 (120) = happyShift action_196
action_164 _ = happyFail (happyExpListPerState 164)

action_165 _ = happyReduce_37

action_166 (81) = happyShift action_30
action_166 (61) = happyGoto action_195
action_166 _ = happyFail (happyExpListPerState 166)

action_167 (120) = happyShift action_61
action_167 (22) = happyGoto action_194
action_167 _ = happyReduce_38

action_168 _ = happyReduce_43

action_169 _ = happyReduce_44

action_170 (120) = happyShift action_96
action_170 (33) = happyGoto action_193
action_170 _ = happyReduce_58

action_171 (121) = happyShift action_192
action_171 _ = happyFail (happyExpListPerState 171)

action_172 (81) = happyShift action_30
action_172 (83) = happyShift action_28
action_172 (120) = happyShift action_73
action_172 (34) = happyGoto action_191
action_172 (56) = happyGoto action_94
action_172 (57) = happyGoto action_70
action_172 (58) = happyGoto action_71
action_172 (59) = happyGoto action_72
action_172 (61) = happyGoto action_38
action_172 _ = happyFail (happyExpListPerState 172)

action_173 (117) = happyShift action_190
action_173 _ = happyFail (happyExpListPerState 173)

action_174 (120) = happyShift action_96
action_174 (33) = happyGoto action_189
action_174 _ = happyReduce_58

action_175 _ = happyReduce_31

action_176 (124) = happyShift action_188
action_176 _ = happyReduce_33

action_177 (120) = happyShift action_96
action_177 (33) = happyGoto action_187
action_177 _ = happyReduce_58

action_178 (81) = happyShift action_30
action_178 (83) = happyShift action_28
action_178 (120) = happyShift action_73
action_178 (56) = happyGoto action_186
action_178 (57) = happyGoto action_70
action_178 (58) = happyGoto action_71
action_178 (59) = happyGoto action_72
action_178 (61) = happyGoto action_38
action_178 _ = happyFail (happyExpListPerState 178)

action_179 (81) = happyShift action_30
action_179 (30) = happyGoto action_185
action_179 (31) = happyGoto action_89
action_179 (61) = happyGoto action_90
action_179 _ = happyReduce_53

action_180 (117) = happyShift action_184
action_180 (38) = happyGoto action_183
action_180 _ = happyReduce_66

action_181 _ = happyReduce_29

action_182 _ = happyReduce_19

action_183 _ = happyReduce_50

action_184 (81) = happyShift action_30
action_184 (83) = happyShift action_28
action_184 (120) = happyShift action_73
action_184 (56) = happyGoto action_257
action_184 (57) = happyGoto action_70
action_184 (58) = happyGoto action_71
action_184 (59) = happyGoto action_72
action_184 (61) = happyGoto action_38
action_184 _ = happyFail (happyExpListPerState 184)

action_185 _ = happyReduce_52

action_186 _ = happyReduce_54

action_187 _ = happyReduce_34

action_188 (83) = happyShift action_28
action_188 (18) = happyGoto action_256
action_188 (19) = happyGoto action_176
action_188 (59) = happyGoto action_177
action_188 _ = happyFail (happyExpListPerState 188)

action_189 (122) = happyShift action_255
action_189 (36) = happyGoto action_254
action_189 _ = happyFail (happyExpListPerState 189)

action_190 (81) = happyShift action_30
action_190 (83) = happyShift action_28
action_190 (120) = happyShift action_73
action_190 (56) = happyGoto action_253
action_190 (57) = happyGoto action_70
action_190 (58) = happyGoto action_71
action_190 (59) = happyGoto action_72
action_190 (61) = happyGoto action_38
action_190 _ = happyFail (happyExpListPerState 190)

action_191 _ = happyReduce_59

action_192 _ = happyReduce_57

action_193 _ = happyReduce_46

action_194 (122) = happyShift action_252
action_194 (21) = happyGoto action_251
action_194 _ = happyFail (happyExpListPerState 194)

action_195 (120) = happyShift action_250
action_195 _ = happyFail (happyExpListPerState 195)

action_196 (81) = happyShift action_30
action_196 (30) = happyGoto action_249
action_196 (31) = happyGoto action_89
action_196 (61) = happyGoto action_90
action_196 _ = happyReduce_53

action_197 (81) = happyShift action_30
action_197 (83) = happyShift action_28
action_197 (120) = happyShift action_73
action_197 (56) = happyGoto action_248
action_197 (57) = happyGoto action_70
action_197 (58) = happyGoto action_71
action_197 (59) = happyGoto action_72
action_197 (61) = happyGoto action_38
action_197 _ = happyFail (happyExpListPerState 197)

action_198 _ = happyReduce_22

action_199 _ = happyReduce_21

action_200 (117) = happyShift action_184
action_200 (38) = happyGoto action_247
action_200 _ = happyReduce_66

action_201 (123) = happyShift action_246
action_201 _ = happyFail (happyExpListPerState 201)

action_202 (124) = happyShift action_203
action_202 (49) = happyGoto action_245
action_202 (50) = happyGoto action_202
action_202 _ = happyReduce_97

action_203 (81) = happyShift action_30
action_203 (82) = happyShift action_52
action_203 (83) = happyShift action_28
action_203 (84) = happyShift action_53
action_203 (118) = happyShift action_243
action_203 (120) = happyShift action_244
action_203 (51) = happyGoto action_238
action_203 (52) = happyGoto action_239
action_203 (55) = happyGoto action_240
action_203 (59) = happyGoto action_241
action_203 (61) = happyGoto action_242
action_203 _ = happyFail (happyExpListPerState 203)

action_204 _ = happyReduce_79

action_205 (120) = happyShift action_217
action_205 (77) = happyGoto action_215
action_205 _ = happyReduce_150

action_206 (96) = happyShift action_237
action_206 (68) = happyGoto action_235
action_206 (69) = happyGoto action_236
action_206 _ = happyReduce_138

action_207 (81) = happyShift action_30
action_207 (82) = happyShift action_143
action_207 (84) = happyShift action_144
action_207 (61) = happyGoto action_205
action_207 (76) = happyGoto action_234
action_207 (79) = happyGoto action_142
action_207 _ = happyFail (happyExpListPerState 207)

action_208 (122) = happyShift action_112
action_208 (63) = happyGoto action_233
action_208 _ = happyFail (happyExpListPerState 208)

action_209 (116) = happyShift action_216
action_209 _ = happyReduce_147

action_210 (114) = happyShift action_232
action_210 (73) = happyGoto action_231
action_210 _ = happyReduce_145

action_211 (81) = happyShift action_30
action_211 (82) = happyShift action_143
action_211 (84) = happyShift action_144
action_211 (61) = happyGoto action_205
action_211 (76) = happyGoto action_230
action_211 (79) = happyGoto action_142
action_211 _ = happyFail (happyExpListPerState 211)

action_212 (81) = happyShift action_30
action_212 (82) = happyShift action_143
action_212 (84) = happyShift action_144
action_212 (87) = happyShift action_145
action_212 (93) = happyShift action_146
action_212 (94) = happyShift action_147
action_212 (95) = happyShift action_148
action_212 (98) = happyShift action_149
action_212 (99) = happyShift action_150
action_212 (100) = happyShift action_151
action_212 (122) = happyShift action_112
action_212 (61) = happyGoto action_131
action_212 (63) = happyGoto action_132
action_212 (64) = happyGoto action_229
action_212 (65) = happyGoto action_134
action_212 (66) = happyGoto action_135
action_212 (67) = happyGoto action_136
action_212 (71) = happyGoto action_137
action_212 (72) = happyGoto action_138
action_212 (74) = happyGoto action_139
action_212 (75) = happyGoto action_140
action_212 (76) = happyGoto action_141
action_212 (79) = happyGoto action_142
action_212 _ = happyReduce_124

action_213 _ = happyReduce_158

action_214 _ = happyReduce_122

action_215 _ = happyReduce_151

action_216 (81) = happyShift action_30
action_216 (61) = happyGoto action_209
action_216 (75) = happyGoto action_228
action_216 _ = happyFail (happyExpListPerState 216)

action_217 (81) = happyShift action_30
action_217 (82) = happyShift action_143
action_217 (84) = happyShift action_144
action_217 (61) = happyGoto action_205
action_217 (76) = happyGoto action_226
action_217 (78) = happyGoto action_227
action_217 (79) = happyGoto action_142
action_217 _ = happyReduce_154

action_218 (88) = happyShift action_129
action_218 (44) = happyGoto action_225
action_218 _ = happyReduce_80

action_219 (89) = happyShift action_119
action_219 _ = happyReduce_81

action_220 _ = happyReduce_92

action_221 _ = happyReduce_90

action_222 (81) = happyShift action_30
action_222 (82) = happyShift action_52
action_222 (83) = happyShift action_28
action_222 (84) = happyShift action_53
action_222 (107) = happyShift action_58
action_222 (120) = happyShift action_59
action_222 (45) = happyGoto action_125
action_222 (48) = happyGoto action_224
action_222 (55) = happyGoto action_48
action_222 (59) = happyGoto action_49
action_222 (61) = happyGoto action_50
action_222 _ = happyReduce_94

action_223 _ = happyReduce_87

action_224 _ = happyReduce_95

action_225 _ = happyReduce_72

action_226 (116) = happyShift action_278
action_226 _ = happyReduce_153

action_227 (121) = happyShift action_277
action_227 _ = happyFail (happyExpListPerState 227)

action_228 _ = happyReduce_148

action_229 _ = happyReduce_123

action_230 _ = happyReduce_146

action_231 _ = happyReduce_143

action_232 (81) = happyShift action_30
action_232 (82) = happyShift action_143
action_232 (84) = happyShift action_144
action_232 (61) = happyGoto action_205
action_232 (76) = happyGoto action_276
action_232 (79) = happyGoto action_142
action_232 _ = happyFail (happyExpListPerState 232)

action_233 _ = happyReduce_142

action_234 (122) = happyShift action_112
action_234 (63) = happyGoto action_275
action_234 _ = happyFail (happyExpListPerState 234)

action_235 (97) = happyShift action_274
action_235 (70) = happyGoto action_273
action_235 _ = happyReduce_141

action_236 (96) = happyShift action_237
action_236 (68) = happyGoto action_272
action_236 (69) = happyGoto action_236
action_236 _ = happyReduce_138

action_237 (82) = happyShift action_143
action_237 (84) = happyShift action_144
action_237 (79) = happyGoto action_271
action_237 _ = happyFail (happyExpListPerState 237)

action_238 (119) = happyShift action_270
action_238 _ = happyFail (happyExpListPerState 238)

action_239 (116) = happyShift action_269
action_239 _ = happyReduce_99

action_240 _ = happyReduce_104

action_241 (120) = happyShift action_268
action_241 (53) = happyGoto action_267
action_241 _ = happyReduce_107

action_242 _ = happyReduce_101

action_243 _ = happyReduce_103

action_244 (81) = happyShift action_30
action_244 (82) = happyShift action_52
action_244 (83) = happyShift action_28
action_244 (84) = happyShift action_53
action_244 (118) = happyShift action_243
action_244 (120) = happyShift action_244
action_244 (52) = happyGoto action_266
action_244 (55) = happyGoto action_240
action_244 (59) = happyGoto action_241
action_244 (61) = happyGoto action_242
action_244 _ = happyFail (happyExpListPerState 244)

action_245 _ = happyReduce_96

action_246 _ = happyReduce_76

action_247 (122) = happyShift action_43
action_247 (40) = happyGoto action_265
action_247 _ = happyFail (happyExpListPerState 247)

action_248 (88) = happyShift action_129
action_248 (44) = happyGoto action_264
action_248 _ = happyReduce_80

action_249 (121) = happyShift action_263
action_249 _ = happyFail (happyExpListPerState 249)

action_250 (81) = happyShift action_30
action_250 (30) = happyGoto action_262
action_250 (31) = happyGoto action_89
action_250 (61) = happyGoto action_90
action_250 _ = happyReduce_53

action_251 _ = happyReduce_35

action_252 (90) = happyShift action_17
action_252 (104) = happyShift action_21
action_252 (28) = happyGoto action_260
action_252 (29) = happyGoto action_261
action_252 _ = happyReduce_48

action_253 _ = happyReduce_115

action_254 _ = happyReduce_56

action_255 (90) = happyShift action_17
action_255 (104) = happyShift action_21
action_255 (29) = happyGoto action_12
action_255 (35) = happyGoto action_258
action_255 (37) = happyGoto action_259
action_255 _ = happyReduce_62

action_256 _ = happyReduce_32

action_257 _ = happyReduce_65

action_258 (123) = happyShift action_294
action_258 _ = happyFail (happyExpListPerState 258)

action_259 (90) = happyShift action_17
action_259 (104) = happyShift action_21
action_259 (29) = happyGoto action_12
action_259 (35) = happyGoto action_293
action_259 (37) = happyGoto action_259
action_259 _ = happyReduce_62

action_260 (123) = happyShift action_292
action_260 _ = happyFail (happyExpListPerState 260)

action_261 (113) = happyShift action_291
action_261 _ = happyFail (happyExpListPerState 261)

action_262 (121) = happyShift action_290
action_262 _ = happyFail (happyExpListPerState 262)

action_263 (122) = happyShift action_43
action_263 (40) = happyGoto action_289
action_263 _ = happyFail (happyExpListPerState 263)

action_264 (113) = happyShift action_288
action_264 _ = happyFail (happyExpListPerState 264)

action_265 _ = happyReduce_89

action_266 (121) = happyShift action_287
action_266 _ = happyFail (happyExpListPerState 266)

action_267 _ = happyReduce_102

action_268 (81) = happyShift action_30
action_268 (82) = happyShift action_52
action_268 (83) = happyShift action_28
action_268 (84) = happyShift action_53
action_268 (118) = happyShift action_243
action_268 (120) = happyShift action_244
action_268 (52) = happyGoto action_285
action_268 (54) = happyGoto action_286
action_268 (55) = happyGoto action_240
action_268 (59) = happyGoto action_241
action_268 (61) = happyGoto action_242
action_268 _ = happyFail (happyExpListPerState 268)

action_269 (81) = happyShift action_30
action_269 (82) = happyShift action_52
action_269 (83) = happyShift action_28
action_269 (84) = happyShift action_53
action_269 (118) = happyShift action_243
action_269 (120) = happyShift action_244
action_269 (51) = happyGoto action_284
action_269 (52) = happyGoto action_239
action_269 (55) = happyGoto action_240
action_269 (59) = happyGoto action_241
action_269 (61) = happyGoto action_242
action_269 _ = happyFail (happyExpListPerState 269)

action_270 (81) = happyShift action_30
action_270 (82) = happyShift action_52
action_270 (83) = happyShift action_28
action_270 (84) = happyShift action_53
action_270 (87) = happyShift action_54
action_270 (101) = happyShift action_55
action_270 (103) = happyShift action_56
action_270 (106) = happyShift action_57
action_270 (107) = happyShift action_58
action_270 (120) = happyShift action_59
action_270 (41) = happyGoto action_283
action_270 (42) = happyGoto action_46
action_270 (45) = happyGoto action_47
action_270 (55) = happyGoto action_48
action_270 (59) = happyGoto action_49
action_270 (61) = happyGoto action_50
action_270 (62) = happyGoto action_51
action_270 _ = happyReduce_70

action_271 (122) = happyShift action_112
action_271 (63) = happyGoto action_282
action_271 _ = happyFail (happyExpListPerState 271)

action_272 _ = happyReduce_137

action_273 _ = happyReduce_136

action_274 (122) = happyShift action_112
action_274 (63) = happyGoto action_281
action_274 _ = happyFail (happyExpListPerState 274)

action_275 (122) = happyShift action_112
action_275 (63) = happyGoto action_280
action_275 _ = happyFail (happyExpListPerState 275)

action_276 _ = happyReduce_144

action_277 _ = happyReduce_152

action_278 (81) = happyShift action_30
action_278 (82) = happyShift action_143
action_278 (84) = happyShift action_144
action_278 (61) = happyGoto action_205
action_278 (76) = happyGoto action_226
action_278 (78) = happyGoto action_279
action_278 (79) = happyGoto action_142
action_278 _ = happyReduce_154

action_279 _ = happyReduce_155

action_280 _ = happyReduce_135

action_281 _ = happyReduce_140

action_282 _ = happyReduce_139

action_283 _ = happyReduce_98

action_284 _ = happyReduce_100

action_285 (116) = happyShift action_298
action_285 _ = happyReduce_108

action_286 (121) = happyShift action_297
action_286 _ = happyFail (happyExpListPerState 286)

action_287 _ = happyReduce_105

action_288 _ = happyReduce_30

action_289 _ = happyReduce_67

action_290 (117) = happyShift action_184
action_290 (38) = happyGoto action_296
action_290 _ = happyReduce_66

action_291 (90) = happyShift action_17
action_291 (104) = happyShift action_21
action_291 (28) = happyGoto action_295
action_291 (29) = happyGoto action_261
action_291 _ = happyReduce_48

action_292 _ = happyReduce_36

action_293 _ = happyReduce_61

action_294 _ = happyReduce_63

action_295 _ = happyReduce_47

action_296 _ = happyReduce_49

action_297 _ = happyReduce_106

action_298 (81) = happyShift action_30
action_298 (82) = happyShift action_52
action_298 (83) = happyShift action_28
action_298 (84) = happyShift action_53
action_298 (118) = happyShift action_243
action_298 (120) = happyShift action_244
action_298 (52) = happyGoto action_285
action_298 (54) = happyGoto action_299
action_298 (55) = happyGoto action_240
action_298 (59) = happyGoto action_241
action_298 (61) = happyGoto action_242
action_298 _ = happyFail (happyExpListPerState 298)

action_299 _ = happyReduce_109

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
	(HappyAbsSyn60  happy_var_2)
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
happyReduction_7 (HappyAbsSyn12  happy_var_1)
	 =  HappyAbsSyn8
		 (TContr happy_var_1
	)
happyReduction_7 _  = notHappyAtAll 

happyReduce_8 = happySpecReduce_1  8 happyReduction_8
happyReduction_8 (HappyAbsSyn37  happy_var_1)
	 =  HappyAbsSyn8
		 (TFunDef happy_var_1
	)
happyReduction_8 _  = notHappyAtAll 

happyReduce_9 = happySpecReduce_1  8 happyReduction_9
happyReduction_9 (HappyAbsSyn20  happy_var_1)
	 =  HappyAbsSyn8
		 (TClassDef happy_var_1
	)
happyReduction_9 _  = notHappyAtAll 

happyReduce_10 = happySpecReduce_1  8 happyReduction_10
happyReduction_10 (HappyAbsSyn32  happy_var_1)
	 =  HappyAbsSyn8
		 (TInstDef happy_var_1
	)
happyReduction_10 _  = notHappyAtAll 

happyReduce_11 = happySpecReduce_1  8 happyReduction_11
happyReduction_11 (HappyAbsSyn17  happy_var_1)
	 =  HappyAbsSyn8
		 (TDataDef happy_var_1
	)
happyReduction_11 _  = notHappyAtAll 

happyReduce_12 = happySpecReduce_1  8 happyReduction_12
happyReduction_12 (HappyAbsSyn15  happy_var_1)
	 =  HappyAbsSyn8
		 (TSym happy_var_1
	)
happyReduction_12 _  = notHappyAtAll 

happyReduce_13 = happySpecReduce_1  8 happyReduction_13
happyReduction_13 (HappyAbsSyn9  happy_var_1)
	 =  HappyAbsSyn8
		 (TPragmaDecl happy_var_1
	)
happyReduction_13 _  = notHappyAtAll 

happyReduce_14 = happyReduce 4 9 happyReduction_14
happyReduction_14 (_ `HappyStk`
	(HappyAbsSyn10  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn9
		 (Pragma NoCoverageCondition happy_var_3
	) `HappyStk` happyRest

happyReduce_15 = happyReduce 4 9 happyReduction_15
happyReduction_15 (_ `HappyStk`
	(HappyAbsSyn10  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn9
		 (Pragma NoPattersonCondition happy_var_3
	) `HappyStk` happyRest

happyReduce_16 = happyReduce 4 9 happyReduction_16
happyReduction_16 (_ `HappyStk`
	(HappyAbsSyn10  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn9
		 (Pragma NoBoundVariableCondition happy_var_3
	) `HappyStk` happyRest

happyReduce_17 = happySpecReduce_1  10 happyReduction_17
happyReduction_17 (HappyAbsSyn11  happy_var_1)
	 =  HappyAbsSyn10
		 (DisableFor happy_var_1
	)
happyReduction_17 _  = notHappyAtAll 

happyReduce_18 = happySpecReduce_0  10 happyReduction_18
happyReduction_18  =  HappyAbsSyn10
		 (DisableAll
	)

happyReduce_19 = happySpecReduce_3  11 happyReduction_19
happyReduction_19 (HappyAbsSyn11  happy_var_3)
	_
	(HappyAbsSyn59  happy_var_1)
	 =  HappyAbsSyn11
		 (cons happy_var_1 happy_var_3
	)
happyReduction_19 _ _ _  = notHappyAtAll 

happyReduce_20 = happySpecReduce_1  11 happyReduction_20
happyReduction_20 (HappyAbsSyn59  happy_var_1)
	 =  HappyAbsSyn11
		 (singleton happy_var_1
	)
happyReduction_20 _  = notHappyAtAll 

happyReduce_21 = happyReduce 6 12 happyReduction_21
happyReduction_21 (_ `HappyStk`
	(HappyAbsSyn13  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn22  happy_var_3) `HappyStk`
	(HappyAbsSyn59  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn12
		 (Contract happy_var_2 happy_var_3 happy_var_5
	) `HappyStk` happyRest

happyReduce_22 = happySpecReduce_2  13 happyReduction_22
happyReduction_22 (HappyAbsSyn13  happy_var_2)
	(HappyAbsSyn14  happy_var_1)
	 =  HappyAbsSyn13
		 (happy_var_1 : happy_var_2
	)
happyReduction_22 _ _  = notHappyAtAll 

happyReduce_23 = happySpecReduce_0  13 happyReduction_23
happyReduction_23  =  HappyAbsSyn13
		 ([]
	)

happyReduce_24 = happySpecReduce_1  14 happyReduction_24
happyReduction_24 (HappyAbsSyn16  happy_var_1)
	 =  HappyAbsSyn14
		 (CFieldDecl happy_var_1
	)
happyReduction_24 _  = notHappyAtAll 

happyReduce_25 = happySpecReduce_1  14 happyReduction_25
happyReduction_25 (HappyAbsSyn17  happy_var_1)
	 =  HappyAbsSyn14
		 (CDataDecl happy_var_1
	)
happyReduction_25 _  = notHappyAtAll 

happyReduce_26 = happySpecReduce_1  14 happyReduction_26
happyReduction_26 (HappyAbsSyn37  happy_var_1)
	 =  HappyAbsSyn14
		 (CFunDecl happy_var_1
	)
happyReduction_26 _  = notHappyAtAll 

happyReduce_27 = happySpecReduce_1  14 happyReduction_27
happyReduction_27 (HappyAbsSyn39  happy_var_1)
	 =  HappyAbsSyn14
		 (CConstrDecl happy_var_1
	)
happyReduction_27 _  = notHappyAtAll 

happyReduce_28 = happySpecReduce_1  14 happyReduction_28
happyReduction_28 (HappyAbsSyn15  happy_var_1)
	 =  HappyAbsSyn14
		 (CSym happy_var_1
	)
happyReduction_28 _  = notHappyAtAll 

happyReduce_29 = happyReduce 5 15 happyReduction_29
happyReduction_29 ((HappyAbsSyn56  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn22  happy_var_3) `HappyStk`
	(HappyAbsSyn59  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn15
		 (TySym happy_var_2 happy_var_3 happy_var_5
	) `HappyStk` happyRest

happyReduce_30 = happyReduce 5 16 happyReduction_30
happyReduction_30 (_ `HappyStk`
	(HappyAbsSyn44  happy_var_4) `HappyStk`
	(HappyAbsSyn56  happy_var_3) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn59  happy_var_1) `HappyStk`
	happyRest)
	 = HappyAbsSyn16
		 (Field happy_var_1 happy_var_3 happy_var_4
	) `HappyStk` happyRest

happyReduce_31 = happyReduce 5 17 happyReduction_31
happyReduction_31 ((HappyAbsSyn18  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn22  happy_var_3) `HappyStk`
	(HappyAbsSyn59  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn17
		 (DataTy happy_var_2 happy_var_3 happy_var_5
	) `HappyStk` happyRest

happyReduce_32 = happySpecReduce_3  18 happyReduction_32
happyReduction_32 (HappyAbsSyn18  happy_var_3)
	_
	(HappyAbsSyn19  happy_var_1)
	 =  HappyAbsSyn18
		 (happy_var_1 : happy_var_3
	)
happyReduction_32 _ _ _  = notHappyAtAll 

happyReduce_33 = happySpecReduce_1  18 happyReduction_33
happyReduction_33 (HappyAbsSyn19  happy_var_1)
	 =  HappyAbsSyn18
		 ([happy_var_1]
	)
happyReduction_33 _  = notHappyAtAll 

happyReduce_34 = happySpecReduce_2  19 happyReduction_34
happyReduction_34 (HappyAbsSyn33  happy_var_2)
	(HappyAbsSyn59  happy_var_1)
	 =  HappyAbsSyn19
		 (Constr happy_var_1 happy_var_2
	)
happyReduction_34 _ _  = notHappyAtAll 

happyReduce_35 = happyReduce 7 20 happyReduction_35
happyReduction_35 ((HappyAbsSyn21  happy_var_7) `HappyStk`
	(HappyAbsSyn22  happy_var_6) `HappyStk`
	(HappyAbsSyn59  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn58  happy_var_3) `HappyStk`
	(HappyAbsSyn24  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn20
		 (Class happy_var_2 happy_var_5 happy_var_6 happy_var_3 happy_var_7
	) `HappyStk` happyRest

happyReduce_36 = happySpecReduce_3  21 happyReduction_36
happyReduction_36 _
	(HappyAbsSyn21  happy_var_2)
	_
	 =  HappyAbsSyn21
		 (happy_var_2
	)
happyReduction_36 _ _ _  = notHappyAtAll 

happyReduce_37 = happySpecReduce_3  22 happyReduction_37
happyReduction_37 _
	(HappyAbsSyn22  happy_var_2)
	_
	 =  HappyAbsSyn22
		 (happy_var_2
	)
happyReduction_37 _ _ _  = notHappyAtAll 

happyReduce_38 = happySpecReduce_0  22 happyReduction_38
happyReduction_38  =  HappyAbsSyn22
		 ([]
	)

happyReduce_39 = happySpecReduce_3  23 happyReduction_39
happyReduction_39 (HappyAbsSyn22  happy_var_3)
	_
	(HappyAbsSyn58  happy_var_1)
	 =  HappyAbsSyn22
		 (happy_var_1 : happy_var_3
	)
happyReduction_39 _ _ _  = notHappyAtAll 

happyReduce_40 = happySpecReduce_1  23 happyReduction_40
happyReduction_40 (HappyAbsSyn58  happy_var_1)
	 =  HappyAbsSyn22
		 ([happy_var_1]
	)
happyReduction_40 _  = notHappyAtAll 

happyReduce_41 = happySpecReduce_0  24 happyReduction_41
happyReduction_41  =  HappyAbsSyn24
		 ([]
	)

happyReduce_42 = happySpecReduce_1  24 happyReduction_42
happyReduction_42 (HappyAbsSyn24  happy_var_1)
	 =  HappyAbsSyn24
		 (happy_var_1
	)
happyReduction_42 _  = notHappyAtAll 

happyReduce_43 = happyReduce 4 25 happyReduction_43
happyReduction_43 (_ `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn24  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn24
		 (happy_var_2
	) `HappyStk` happyRest

happyReduce_44 = happySpecReduce_3  26 happyReduction_44
happyReduction_44 (HappyAbsSyn24  happy_var_3)
	_
	(HappyAbsSyn27  happy_var_1)
	 =  HappyAbsSyn24
		 (happy_var_1 : happy_var_3
	)
happyReduction_44 _ _ _  = notHappyAtAll 

happyReduce_45 = happySpecReduce_1  26 happyReduction_45
happyReduction_45 (HappyAbsSyn27  happy_var_1)
	 =  HappyAbsSyn24
		 ([happy_var_1]
	)
happyReduction_45 _  = notHappyAtAll 

happyReduce_46 = happyReduce 4 27 happyReduction_46
happyReduction_46 ((HappyAbsSyn33  happy_var_4) `HappyStk`
	(HappyAbsSyn59  happy_var_3) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn56  happy_var_1) `HappyStk`
	happyRest)
	 = HappyAbsSyn27
		 (InCls happy_var_3 happy_var_1 happy_var_4
	) `HappyStk` happyRest

happyReduce_47 = happySpecReduce_3  28 happyReduction_47
happyReduction_47 (HappyAbsSyn21  happy_var_3)
	_
	(HappyAbsSyn29  happy_var_1)
	 =  HappyAbsSyn21
		 (happy_var_1 : happy_var_3
	)
happyReduction_47 _ _ _  = notHappyAtAll 

happyReduce_48 = happySpecReduce_0  28 happyReduction_48
happyReduction_48  =  HappyAbsSyn21
		 ([]
	)

happyReduce_49 = happyReduce 10 29 happyReduction_49
happyReduction_49 ((HappyAbsSyn38  happy_var_10) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn30  happy_var_8) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn59  happy_var_6) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn24  happy_var_4) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn22  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn29
		 (Signature happy_var_2 happy_var_4 happy_var_6 happy_var_8 happy_var_10
	) `HappyStk` happyRest

happyReduce_50 = happyReduce 6 29 happyReduction_50
happyReduction_50 ((HappyAbsSyn38  happy_var_6) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn30  happy_var_4) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn59  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn29
		 (Signature [] [] happy_var_2 happy_var_4 happy_var_6
	) `HappyStk` happyRest

happyReduce_51 = happySpecReduce_1  30 happyReduction_51
happyReduction_51 (HappyAbsSyn31  happy_var_1)
	 =  HappyAbsSyn30
		 ([happy_var_1]
	)
happyReduction_51 _  = notHappyAtAll 

happyReduce_52 = happySpecReduce_3  30 happyReduction_52
happyReduction_52 (HappyAbsSyn30  happy_var_3)
	_
	(HappyAbsSyn31  happy_var_1)
	 =  HappyAbsSyn30
		 (happy_var_1 : happy_var_3
	)
happyReduction_52 _ _ _  = notHappyAtAll 

happyReduce_53 = happySpecReduce_0  30 happyReduction_53
happyReduction_53  =  HappyAbsSyn30
		 ([]
	)

happyReduce_54 = happySpecReduce_3  31 happyReduction_54
happyReduction_54 (HappyAbsSyn56  happy_var_3)
	_
	(HappyAbsSyn59  happy_var_1)
	 =  HappyAbsSyn31
		 (Typed happy_var_1 happy_var_3
	)
happyReduction_54 _ _ _  = notHappyAtAll 

happyReduce_55 = happySpecReduce_1  31 happyReduction_55
happyReduction_55 (HappyAbsSyn59  happy_var_1)
	 =  HappyAbsSyn31
		 (Untyped happy_var_1
	)
happyReduction_55 _  = notHappyAtAll 

happyReduce_56 = happyReduce 7 32 happyReduction_56
happyReduction_56 ((HappyAbsSyn35  happy_var_7) `HappyStk`
	(HappyAbsSyn33  happy_var_6) `HappyStk`
	(HappyAbsSyn59  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn56  happy_var_3) `HappyStk`
	(HappyAbsSyn24  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn32
		 (Instance happy_var_2 happy_var_5 happy_var_6 happy_var_3 happy_var_7
	) `HappyStk` happyRest

happyReduce_57 = happySpecReduce_3  33 happyReduction_57
happyReduction_57 _
	(HappyAbsSyn33  happy_var_2)
	_
	 =  HappyAbsSyn33
		 (happy_var_2
	)
happyReduction_57 _ _ _  = notHappyAtAll 

happyReduce_58 = happySpecReduce_0  33 happyReduction_58
happyReduction_58  =  HappyAbsSyn33
		 ([]
	)

happyReduce_59 = happySpecReduce_3  34 happyReduction_59
happyReduction_59 (HappyAbsSyn33  happy_var_3)
	_
	(HappyAbsSyn56  happy_var_1)
	 =  HappyAbsSyn33
		 (happy_var_1 : happy_var_3
	)
happyReduction_59 _ _ _  = notHappyAtAll 

happyReduce_60 = happySpecReduce_1  34 happyReduction_60
happyReduction_60 (HappyAbsSyn56  happy_var_1)
	 =  HappyAbsSyn33
		 ([happy_var_1]
	)
happyReduction_60 _  = notHappyAtAll 

happyReduce_61 = happySpecReduce_2  35 happyReduction_61
happyReduction_61 (HappyAbsSyn35  happy_var_2)
	(HappyAbsSyn37  happy_var_1)
	 =  HappyAbsSyn35
		 (happy_var_1 : happy_var_2
	)
happyReduction_61 _ _  = notHappyAtAll 

happyReduce_62 = happySpecReduce_0  35 happyReduction_62
happyReduction_62  =  HappyAbsSyn35
		 ([]
	)

happyReduce_63 = happySpecReduce_3  36 happyReduction_63
happyReduction_63 _
	(HappyAbsSyn35  happy_var_2)
	_
	 =  HappyAbsSyn35
		 (happy_var_2
	)
happyReduction_63 _ _ _  = notHappyAtAll 

happyReduce_64 = happySpecReduce_2  37 happyReduction_64
happyReduction_64 (HappyAbsSyn40  happy_var_2)
	(HappyAbsSyn29  happy_var_1)
	 =  HappyAbsSyn37
		 (FunDef happy_var_1 happy_var_2
	)
happyReduction_64 _ _  = notHappyAtAll 

happyReduce_65 = happySpecReduce_2  38 happyReduction_65
happyReduction_65 (HappyAbsSyn56  happy_var_2)
	_
	 =  HappyAbsSyn38
		 (Just happy_var_2
	)
happyReduction_65 _ _  = notHappyAtAll 

happyReduce_66 = happySpecReduce_0  38 happyReduction_66
happyReduction_66  =  HappyAbsSyn38
		 (Nothing
	)

happyReduce_67 = happyReduce 5 39 happyReduction_67
happyReduction_67 ((HappyAbsSyn40  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn30  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn39
		 (Constructor happy_var_3 happy_var_5
	) `HappyStk` happyRest

happyReduce_68 = happySpecReduce_3  40 happyReduction_68
happyReduction_68 _
	(HappyAbsSyn40  happy_var_2)
	_
	 =  HappyAbsSyn40
		 (happy_var_2
	)
happyReduction_68 _ _ _  = notHappyAtAll 

happyReduce_69 = happySpecReduce_3  41 happyReduction_69
happyReduction_69 (HappyAbsSyn40  happy_var_3)
	_
	(HappyAbsSyn42  happy_var_1)
	 =  HappyAbsSyn40
		 (happy_var_1 : happy_var_3
	)
happyReduction_69 _ _ _  = notHappyAtAll 

happyReduce_70 = happySpecReduce_0  41 happyReduction_70
happyReduction_70  =  HappyAbsSyn40
		 ([]
	)

happyReduce_71 = happySpecReduce_3  42 happyReduction_71
happyReduction_71 (HappyAbsSyn45  happy_var_3)
	_
	(HappyAbsSyn45  happy_var_1)
	 =  HappyAbsSyn42
		 (happy_var_1 := happy_var_3
	)
happyReduction_71 _ _ _  = notHappyAtAll 

happyReduce_72 = happyReduce 5 42 happyReduction_72
happyReduction_72 ((HappyAbsSyn44  happy_var_5) `HappyStk`
	(HappyAbsSyn56  happy_var_4) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn59  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn42
		 (Let happy_var_2 (Just happy_var_4) happy_var_5
	) `HappyStk` happyRest

happyReduce_73 = happySpecReduce_3  42 happyReduction_73
happyReduction_73 (HappyAbsSyn44  happy_var_3)
	(HappyAbsSyn59  happy_var_2)
	_
	 =  HappyAbsSyn42
		 (Let happy_var_2 Nothing happy_var_3
	)
happyReduction_73 _ _ _  = notHappyAtAll 

happyReduce_74 = happySpecReduce_1  42 happyReduction_74
happyReduction_74 (HappyAbsSyn45  happy_var_1)
	 =  HappyAbsSyn42
		 (StmtExp happy_var_1
	)
happyReduction_74 _  = notHappyAtAll 

happyReduce_75 = happySpecReduce_2  42 happyReduction_75
happyReduction_75 (HappyAbsSyn45  happy_var_2)
	_
	 =  HappyAbsSyn42
		 (Return happy_var_2
	)
happyReduction_75 _ _  = notHappyAtAll 

happyReduce_76 = happyReduce 5 42 happyReduction_76
happyReduction_76 (_ `HappyStk`
	(HappyAbsSyn49  happy_var_4) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn43  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn42
		 (Match happy_var_2 happy_var_4
	) `HappyStk` happyRest

happyReduce_77 = happySpecReduce_1  42 happyReduction_77
happyReduction_77 (HappyAbsSyn62  happy_var_1)
	 =  HappyAbsSyn42
		 (Asm happy_var_1
	)
happyReduction_77 _  = notHappyAtAll 

happyReduce_78 = happySpecReduce_1  43 happyReduction_78
happyReduction_78 (HappyAbsSyn45  happy_var_1)
	 =  HappyAbsSyn43
		 ([happy_var_1]
	)
happyReduction_78 _  = notHappyAtAll 

happyReduce_79 = happySpecReduce_3  43 happyReduction_79
happyReduction_79 (HappyAbsSyn43  happy_var_3)
	_
	(HappyAbsSyn45  happy_var_1)
	 =  HappyAbsSyn43
		 (happy_var_1 : happy_var_3
	)
happyReduction_79 _ _ _  = notHappyAtAll 

happyReduce_80 = happySpecReduce_0  44 happyReduction_80
happyReduction_80  =  HappyAbsSyn44
		 (Nothing
	)

happyReduce_81 = happySpecReduce_2  44 happyReduction_81
happyReduction_81 (HappyAbsSyn45  happy_var_2)
	_
	 =  HappyAbsSyn44
		 (Just happy_var_2
	)
happyReduction_81 _ _  = notHappyAtAll 

happyReduce_82 = happySpecReduce_1  45 happyReduction_82
happyReduction_82 (HappyAbsSyn59  happy_var_1)
	 =  HappyAbsSyn45
		 (Var happy_var_1
	)
happyReduction_82 _  = notHappyAtAll 

happyReduce_83 = happySpecReduce_2  45 happyReduction_83
happyReduction_83 (HappyAbsSyn43  happy_var_2)
	(HappyAbsSyn59  happy_var_1)
	 =  HappyAbsSyn45
		 (Con happy_var_1 happy_var_2
	)
happyReduction_83 _ _  = notHappyAtAll 

happyReduce_84 = happySpecReduce_1  45 happyReduction_84
happyReduction_84 (HappyAbsSyn55  happy_var_1)
	 =  HappyAbsSyn45
		 (Lit happy_var_1
	)
happyReduction_84 _  = notHappyAtAll 

happyReduce_85 = happySpecReduce_3  45 happyReduction_85
happyReduction_85 _
	(HappyAbsSyn45  happy_var_2)
	_
	 =  HappyAbsSyn45
		 (happy_var_2
	)
happyReduction_85 _ _ _  = notHappyAtAll 

happyReduce_86 = happySpecReduce_3  45 happyReduction_86
happyReduction_86 (HappyAbsSyn59  happy_var_3)
	_
	(HappyAbsSyn45  happy_var_1)
	 =  HappyAbsSyn45
		 (FieldAccess happy_var_1 happy_var_3
	)
happyReduction_86 _ _ _  = notHappyAtAll 

happyReduce_87 = happyReduce 4 45 happyReduction_87
happyReduction_87 ((HappyAbsSyn43  happy_var_4) `HappyStk`
	(HappyAbsSyn59  happy_var_3) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn45  happy_var_1) `HappyStk`
	happyRest)
	 = HappyAbsSyn45
		 (Call (Just happy_var_1) happy_var_3 happy_var_4
	) `HappyStk` happyRest

happyReduce_88 = happySpecReduce_2  45 happyReduction_88
happyReduction_88 (HappyAbsSyn43  happy_var_2)
	(HappyAbsSyn59  happy_var_1)
	 =  HappyAbsSyn45
		 (Call Nothing happy_var_1 happy_var_2
	)
happyReduction_88 _ _  = notHappyAtAll 

happyReduce_89 = happyReduce 6 45 happyReduction_89
happyReduction_89 ((HappyAbsSyn40  happy_var_6) `HappyStk`
	(HappyAbsSyn38  happy_var_5) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn30  happy_var_3) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn45
		 (Lam happy_var_3 happy_var_6 happy_var_5
	) `HappyStk` happyRest

happyReduce_90 = happySpecReduce_3  46 happyReduction_90
happyReduction_90 _
	(HappyAbsSyn43  happy_var_2)
	_
	 =  HappyAbsSyn43
		 (happy_var_2
	)
happyReduction_90 _ _ _  = notHappyAtAll 

happyReduce_91 = happySpecReduce_0  46 happyReduction_91
happyReduction_91  =  HappyAbsSyn43
		 ([]
	)

happyReduce_92 = happySpecReduce_3  47 happyReduction_92
happyReduction_92 _
	(HappyAbsSyn43  happy_var_2)
	_
	 =  HappyAbsSyn43
		 (happy_var_2
	)
happyReduction_92 _ _ _  = notHappyAtAll 

happyReduce_93 = happySpecReduce_1  48 happyReduction_93
happyReduction_93 (HappyAbsSyn45  happy_var_1)
	 =  HappyAbsSyn43
		 ([happy_var_1]
	)
happyReduction_93 _  = notHappyAtAll 

happyReduce_94 = happySpecReduce_0  48 happyReduction_94
happyReduction_94  =  HappyAbsSyn43
		 ([]
	)

happyReduce_95 = happySpecReduce_3  48 happyReduction_95
happyReduction_95 (HappyAbsSyn43  happy_var_3)
	_
	(HappyAbsSyn45  happy_var_1)
	 =  HappyAbsSyn43
		 (happy_var_1 : happy_var_3
	)
happyReduction_95 _ _ _  = notHappyAtAll 

happyReduce_96 = happySpecReduce_2  49 happyReduction_96
happyReduction_96 (HappyAbsSyn49  happy_var_2)
	(HappyAbsSyn50  happy_var_1)
	 =  HappyAbsSyn49
		 (happy_var_1 : happy_var_2
	)
happyReduction_96 _ _  = notHappyAtAll 

happyReduce_97 = happySpecReduce_0  49 happyReduction_97
happyReduction_97  =  HappyAbsSyn49
		 ([]
	)

happyReduce_98 = happyReduce 4 50 happyReduction_98
happyReduction_98 ((HappyAbsSyn40  happy_var_4) `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn51  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn50
		 ((happy_var_2, happy_var_4)
	) `HappyStk` happyRest

happyReduce_99 = happySpecReduce_1  51 happyReduction_99
happyReduction_99 (HappyAbsSyn52  happy_var_1)
	 =  HappyAbsSyn51
		 ([happy_var_1]
	)
happyReduction_99 _  = notHappyAtAll 

happyReduce_100 = happySpecReduce_3  51 happyReduction_100
happyReduction_100 (HappyAbsSyn51  happy_var_3)
	_
	(HappyAbsSyn52  happy_var_1)
	 =  HappyAbsSyn51
		 (happy_var_1 : happy_var_3
	)
happyReduction_100 _ _ _  = notHappyAtAll 

happyReduce_101 = happySpecReduce_1  52 happyReduction_101
happyReduction_101 (HappyAbsSyn59  happy_var_1)
	 =  HappyAbsSyn52
		 (PVar happy_var_1
	)
happyReduction_101 _  = notHappyAtAll 

happyReduce_102 = happySpecReduce_2  52 happyReduction_102
happyReduction_102 (HappyAbsSyn51  happy_var_2)
	(HappyAbsSyn59  happy_var_1)
	 =  HappyAbsSyn52
		 (PCon happy_var_1 happy_var_2
	)
happyReduction_102 _ _  = notHappyAtAll 

happyReduce_103 = happySpecReduce_1  52 happyReduction_103
happyReduction_103 _
	 =  HappyAbsSyn52
		 (PWildcard
	)

happyReduce_104 = happySpecReduce_1  52 happyReduction_104
happyReduction_104 (HappyAbsSyn55  happy_var_1)
	 =  HappyAbsSyn52
		 (PLit happy_var_1
	)
happyReduction_104 _  = notHappyAtAll 

happyReduce_105 = happySpecReduce_3  52 happyReduction_105
happyReduction_105 _
	(HappyAbsSyn52  happy_var_2)
	_
	 =  HappyAbsSyn52
		 (happy_var_2
	)
happyReduction_105 _ _ _  = notHappyAtAll 

happyReduce_106 = happySpecReduce_3  53 happyReduction_106
happyReduction_106 _
	(HappyAbsSyn51  happy_var_2)
	_
	 =  HappyAbsSyn51
		 (happy_var_2
	)
happyReduction_106 _ _ _  = notHappyAtAll 

happyReduce_107 = happySpecReduce_0  53 happyReduction_107
happyReduction_107  =  HappyAbsSyn51
		 ([]
	)

happyReduce_108 = happySpecReduce_1  54 happyReduction_108
happyReduction_108 (HappyAbsSyn52  happy_var_1)
	 =  HappyAbsSyn51
		 ([happy_var_1]
	)
happyReduction_108 _  = notHappyAtAll 

happyReduce_109 = happySpecReduce_3  54 happyReduction_109
happyReduction_109 (HappyAbsSyn51  happy_var_3)
	_
	(HappyAbsSyn52  happy_var_1)
	 =  HappyAbsSyn51
		 (happy_var_1 : happy_var_3
	)
happyReduction_109 _ _ _  = notHappyAtAll 

happyReduce_110 = happySpecReduce_1  55 happyReduction_110
happyReduction_110 (HappyTerminal (Token _ (TNumber happy_var_1)))
	 =  HappyAbsSyn55
		 (IntLit $ toInteger happy_var_1
	)
happyReduction_110 _  = notHappyAtAll 

happyReduce_111 = happySpecReduce_1  55 happyReduction_111
happyReduction_111 (HappyTerminal (Token _ (TString happy_var_1)))
	 =  HappyAbsSyn55
		 (StrLit happy_var_1
	)
happyReduction_111 _  = notHappyAtAll 

happyReduce_112 = happySpecReduce_2  56 happyReduction_112
happyReduction_112 (HappyAbsSyn33  happy_var_2)
	(HappyAbsSyn59  happy_var_1)
	 =  HappyAbsSyn56
		 (TyCon happy_var_1 happy_var_2
	)
happyReduction_112 _ _  = notHappyAtAll 

happyReduce_113 = happySpecReduce_1  56 happyReduction_113
happyReduction_113 (HappyAbsSyn58  happy_var_1)
	 =  HappyAbsSyn56
		 (TyVar  happy_var_1
	)
happyReduction_113 _  = notHappyAtAll 

happyReduce_114 = happySpecReduce_1  56 happyReduction_114
happyReduction_114 (HappyAbsSyn57  happy_var_1)
	 =  HappyAbsSyn56
		 (uncurry funtype happy_var_1
	)
happyReduction_114 _  = notHappyAtAll 

happyReduce_115 = happyReduce 5 57 happyReduction_115
happyReduction_115 ((HappyAbsSyn56  happy_var_5) `HappyStk`
	_ `HappyStk`
	_ `HappyStk`
	(HappyAbsSyn33  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn57
		 ((happy_var_2, happy_var_5)
	) `HappyStk` happyRest

happyReduce_116 = happySpecReduce_1  58 happyReduction_116
happyReduction_116 (HappyAbsSyn59  happy_var_1)
	 =  HappyAbsSyn58
		 (TVar happy_var_1
	)
happyReduction_116 _  = notHappyAtAll 

happyReduce_117 = happySpecReduce_1  59 happyReduction_117
happyReduction_117 (HappyTerminal (Token _ (TTycon happy_var_1)))
	 =  HappyAbsSyn59
		 (Name happy_var_1
	)
happyReduction_117 _  = notHappyAtAll 

happyReduce_118 = happySpecReduce_1  60 happyReduction_118
happyReduction_118 (HappyAbsSyn59  happy_var_1)
	 =  HappyAbsSyn60
		 ([happy_var_1]
	)
happyReduction_118 _  = notHappyAtAll 

happyReduce_119 = happySpecReduce_3  60 happyReduction_119
happyReduction_119 (HappyAbsSyn59  happy_var_3)
	_
	(HappyAbsSyn60  happy_var_1)
	 =  HappyAbsSyn60
		 (happy_var_3 : happy_var_1
	)
happyReduction_119 _ _ _  = notHappyAtAll 

happyReduce_120 = happySpecReduce_1  61 happyReduction_120
happyReduction_120 (HappyTerminal (Token _ (TIdent happy_var_1)))
	 =  HappyAbsSyn59
		 (Name happy_var_1
	)
happyReduction_120 _  = notHappyAtAll 

happyReduce_121 = happySpecReduce_2  62 happyReduction_121
happyReduction_121 (HappyAbsSyn62  happy_var_2)
	_
	 =  HappyAbsSyn62
		 (happy_var_2
	)
happyReduction_121 _ _  = notHappyAtAll 

happyReduce_122 = happySpecReduce_3  63 happyReduction_122
happyReduction_122 _
	(HappyAbsSyn64  happy_var_2)
	_
	 =  HappyAbsSyn62
		 (happy_var_2
	)
happyReduction_122 _ _ _  = notHappyAtAll 

happyReduce_123 = happySpecReduce_3  64 happyReduction_123
happyReduction_123 (HappyAbsSyn64  happy_var_3)
	_
	(HappyAbsSyn65  happy_var_1)
	 =  HappyAbsSyn64
		 (happy_var_1 : happy_var_3
	)
happyReduction_123 _ _ _  = notHappyAtAll 

happyReduce_124 = happySpecReduce_0  64 happyReduction_124
happyReduction_124  =  HappyAbsSyn64
		 ([]
	)

happyReduce_125 = happySpecReduce_1  65 happyReduction_125
happyReduction_125 (HappyAbsSyn65  happy_var_1)
	 =  HappyAbsSyn65
		 (happy_var_1
	)
happyReduction_125 _  = notHappyAtAll 

happyReduce_126 = happySpecReduce_1  65 happyReduction_126
happyReduction_126 (HappyAbsSyn62  happy_var_1)
	 =  HappyAbsSyn65
		 (YBlock happy_var_1
	)
happyReduction_126 _  = notHappyAtAll 

happyReduce_127 = happySpecReduce_1  65 happyReduction_127
happyReduction_127 (HappyAbsSyn65  happy_var_1)
	 =  HappyAbsSyn65
		 (happy_var_1
	)
happyReduction_127 _  = notHappyAtAll 

happyReduce_128 = happySpecReduce_1  65 happyReduction_128
happyReduction_128 (HappyAbsSyn76  happy_var_1)
	 =  HappyAbsSyn65
		 (YExp happy_var_1
	)
happyReduction_128 _  = notHappyAtAll 

happyReduce_129 = happySpecReduce_1  65 happyReduction_129
happyReduction_129 (HappyAbsSyn65  happy_var_1)
	 =  HappyAbsSyn65
		 (happy_var_1
	)
happyReduction_129 _  = notHappyAtAll 

happyReduce_130 = happySpecReduce_1  65 happyReduction_130
happyReduction_130 (HappyAbsSyn65  happy_var_1)
	 =  HappyAbsSyn65
		 (happy_var_1
	)
happyReduction_130 _  = notHappyAtAll 

happyReduce_131 = happySpecReduce_1  65 happyReduction_131
happyReduction_131 (HappyAbsSyn65  happy_var_1)
	 =  HappyAbsSyn65
		 (happy_var_1
	)
happyReduction_131 _  = notHappyAtAll 

happyReduce_132 = happySpecReduce_1  65 happyReduction_132
happyReduction_132 _
	 =  HappyAbsSyn65
		 (YContinue
	)

happyReduce_133 = happySpecReduce_1  65 happyReduction_133
happyReduction_133 _
	 =  HappyAbsSyn65
		 (YBreak
	)

happyReduce_134 = happySpecReduce_1  65 happyReduction_134
happyReduction_134 _
	 =  HappyAbsSyn65
		 (YLeave
	)

happyReduce_135 = happyReduce 5 66 happyReduction_135
happyReduction_135 ((HappyAbsSyn62  happy_var_5) `HappyStk`
	(HappyAbsSyn62  happy_var_4) `HappyStk`
	(HappyAbsSyn76  happy_var_3) `HappyStk`
	(HappyAbsSyn62  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn65
		 (YFor happy_var_2 happy_var_3 happy_var_4 happy_var_5
	) `HappyStk` happyRest

happyReduce_136 = happyReduce 4 67 happyReduction_136
happyReduction_136 ((HappyAbsSyn70  happy_var_4) `HappyStk`
	(HappyAbsSyn68  happy_var_3) `HappyStk`
	(HappyAbsSyn76  happy_var_2) `HappyStk`
	_ `HappyStk`
	happyRest)
	 = HappyAbsSyn65
		 (YSwitch happy_var_2 happy_var_3 happy_var_4
	) `HappyStk` happyRest

happyReduce_137 = happySpecReduce_2  68 happyReduction_137
happyReduction_137 (HappyAbsSyn68  happy_var_2)
	(HappyAbsSyn69  happy_var_1)
	 =  HappyAbsSyn68
		 (happy_var_1 : happy_var_2
	)
happyReduction_137 _ _  = notHappyAtAll 

happyReduce_138 = happySpecReduce_0  68 happyReduction_138
happyReduction_138  =  HappyAbsSyn68
		 ([]
	)

happyReduce_139 = happySpecReduce_3  69 happyReduction_139
happyReduction_139 (HappyAbsSyn62  happy_var_3)
	(HappyAbsSyn79  happy_var_2)
	_
	 =  HappyAbsSyn69
		 ((happy_var_2, happy_var_3)
	)
happyReduction_139 _ _ _  = notHappyAtAll 

happyReduce_140 = happySpecReduce_2  70 happyReduction_140
happyReduction_140 (HappyAbsSyn62  happy_var_2)
	_
	 =  HappyAbsSyn70
		 (Just happy_var_2
	)
happyReduction_140 _ _  = notHappyAtAll 

happyReduce_141 = happySpecReduce_0  70 happyReduction_141
happyReduction_141  =  HappyAbsSyn70
		 (Nothing
	)

happyReduce_142 = happySpecReduce_3  71 happyReduction_142
happyReduction_142 (HappyAbsSyn62  happy_var_3)
	(HappyAbsSyn76  happy_var_2)
	_
	 =  HappyAbsSyn65
		 (YIf happy_var_2 happy_var_3
	)
happyReduction_142 _ _ _  = notHappyAtAll 

happyReduce_143 = happySpecReduce_3  72 happyReduction_143
happyReduction_143 (HappyAbsSyn73  happy_var_3)
	(HappyAbsSyn60  happy_var_2)
	_
	 =  HappyAbsSyn65
		 (YLet happy_var_2 happy_var_3
	)
happyReduction_143 _ _ _  = notHappyAtAll 

happyReduce_144 = happySpecReduce_2  73 happyReduction_144
happyReduction_144 (HappyAbsSyn76  happy_var_2)
	_
	 =  HappyAbsSyn73
		 (Just happy_var_2
	)
happyReduction_144 _ _  = notHappyAtAll 

happyReduce_145 = happySpecReduce_0  73 happyReduction_145
happyReduction_145  =  HappyAbsSyn73
		 (Nothing
	)

happyReduce_146 = happySpecReduce_3  74 happyReduction_146
happyReduction_146 (HappyAbsSyn76  happy_var_3)
	_
	(HappyAbsSyn60  happy_var_1)
	 =  HappyAbsSyn65
		 (YAssign happy_var_1 happy_var_3
	)
happyReduction_146 _ _ _  = notHappyAtAll 

happyReduce_147 = happySpecReduce_1  75 happyReduction_147
happyReduction_147 (HappyAbsSyn59  happy_var_1)
	 =  HappyAbsSyn60
		 ([happy_var_1]
	)
happyReduction_147 _  = notHappyAtAll 

happyReduce_148 = happySpecReduce_3  75 happyReduction_148
happyReduction_148 (HappyAbsSyn60  happy_var_3)
	_
	(HappyAbsSyn59  happy_var_1)
	 =  HappyAbsSyn60
		 (happy_var_1 : happy_var_3
	)
happyReduction_148 _ _ _  = notHappyAtAll 

happyReduce_149 = happySpecReduce_1  76 happyReduction_149
happyReduction_149 (HappyAbsSyn79  happy_var_1)
	 =  HappyAbsSyn76
		 (YLit happy_var_1
	)
happyReduction_149 _  = notHappyAtAll 

happyReduce_150 = happySpecReduce_1  76 happyReduction_150
happyReduction_150 (HappyAbsSyn59  happy_var_1)
	 =  HappyAbsSyn76
		 (YIdent happy_var_1
	)
happyReduction_150 _  = notHappyAtAll 

happyReduce_151 = happySpecReduce_2  76 happyReduction_151
happyReduction_151 (HappyAbsSyn77  happy_var_2)
	(HappyAbsSyn59  happy_var_1)
	 =  HappyAbsSyn76
		 (YCall happy_var_1 happy_var_2
	)
happyReduction_151 _ _  = notHappyAtAll 

happyReduce_152 = happySpecReduce_3  77 happyReduction_152
happyReduction_152 _
	(HappyAbsSyn77  happy_var_2)
	_
	 =  HappyAbsSyn77
		 (happy_var_2
	)
happyReduction_152 _ _ _  = notHappyAtAll 

happyReduce_153 = happySpecReduce_1  78 happyReduction_153
happyReduction_153 (HappyAbsSyn76  happy_var_1)
	 =  HappyAbsSyn77
		 ([happy_var_1]
	)
happyReduction_153 _  = notHappyAtAll 

happyReduce_154 = happySpecReduce_0  78 happyReduction_154
happyReduction_154  =  HappyAbsSyn77
		 ([]
	)

happyReduce_155 = happySpecReduce_3  78 happyReduction_155
happyReduction_155 (HappyAbsSyn77  happy_var_3)
	_
	(HappyAbsSyn76  happy_var_1)
	 =  HappyAbsSyn77
		 (happy_var_1 : happy_var_3
	)
happyReduction_155 _ _ _  = notHappyAtAll 

happyReduce_156 = happySpecReduce_1  79 happyReduction_156
happyReduction_156 (HappyTerminal (Token _ (TNumber happy_var_1)))
	 =  HappyAbsSyn79
		 (YulNumber $ toInteger happy_var_1
	)
happyReduction_156 _  = notHappyAtAll 

happyReduce_157 = happySpecReduce_1  79 happyReduction_157
happyReduction_157 (HappyTerminal (Token _ (TString happy_var_1)))
	 =  HappyAbsSyn79
		 (YulString happy_var_1
	)
happyReduction_157 _  = notHappyAtAll 

happyReduce_158 = happySpecReduce_1  80 happyReduction_158
happyReduction_158 _
	 =  HappyAbsSyn80
		 (()
	)

happyReduce_159 = happySpecReduce_0  80 happyReduction_159
happyReduction_159  =  HappyAbsSyn80
		 (()
	)

happyNewToken action sts stk
	= lexer(\tk -> 
	let cont i = action i i tk (HappyState action) sts stk in
	case tk of {
	Token _ TEOF -> action 125 125 tk (HappyState action) sts stk;
	Token _ (TIdent happy_dollar_dollar) -> cont 81;
	Token _ (TNumber happy_dollar_dollar) -> cont 82;
	Token _ (TTycon happy_dollar_dollar) -> cont 83;
	Token _ (TString happy_dollar_dollar) -> cont 84;
	Token _ TContract -> cont 85;
	Token _ TImport -> cont 86;
	Token _ TLet -> cont 87;
	Token _ TEq -> cont 88;
	Token _ TDot -> cont 89;
	Token _ TForall -> cont 90;
	Token _ TClass -> cont 91;
	Token _ TInstance -> cont 92;
	Token _ TIf -> cont 93;
	Token _ TFor -> cont 94;
	Token _ TSwitch -> cont 95;
	Token _ TCase -> cont 96;
	Token _ TDefault -> cont 97;
	Token _ TLeave -> cont 98;
	Token _ TContinue -> cont 99;
	Token _ TBreak -> cont 100;
	Token _ TAssembly -> cont 101;
	Token _ TData -> cont 102;
	Token _ TMatch -> cont 103;
	Token _ TFunction -> cont 104;
	Token _ TConstructor -> cont 105;
	Token _ TReturn -> cont 106;
	Token _ TLam -> cont 107;
	Token _ TType -> cont 108;
	Token _ TNoPattersonCondition -> cont 109;
	Token _ TNoCoverageCondition -> cont 110;
	Token _ TNoBoundVariableCondition -> cont 111;
	Token _ TPragma -> cont 112;
	Token _ TSemi -> cont 113;
	Token _ TYAssign -> cont 114;
	Token _ TColon -> cont 115;
	Token _ TComma -> cont 116;
	Token _ TArrow -> cont 117;
	Token _ TWildCard -> cont 118;
	Token _ TDArrow -> cont 119;
	Token _ TLParen -> cont 120;
	Token _ TRParen -> cont 121;
	Token _ TLBrace -> cont 122;
	Token _ TRBrace -> cont 123;
	Token _ TBar -> cont 124;
	_ -> happyError' (tk, [])
	})

happyError_ explist 125 tk = happyError' (tk, explist)
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


parseError (Token (line, col) lexeme)
  = alexError $ "Parse error while processing lexeme: " ++ show lexeme
                ++ "\n at line " ++ show line ++ ", column " ++ show col

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
