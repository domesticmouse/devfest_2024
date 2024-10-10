// Copyright 2024 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:checked_yaml/checked_yaml.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:syntax_highlight/syntax_highlight.dart';

import 'configuration.dart';

part 'providers.g.dart';

@riverpod
Future<Configuration> configuration(ConfigurationRef ref) async {
  final yaml = await rootBundle.loadString('assets/steps.yaml');
  return checkedYamlDecode(yaml, (m) => Configuration.fromJson(m!));
}

class Highlighters {
  Highlighters({
    required this.dart,
    required this.glsl,
    required this.json,
    required this.yaml,
    required this.xml,
  });
  Highlighter dart;
  Highlighter glsl;
  Highlighter json;
  Highlighter yaml;
  Highlighter xml;
}

@riverpod
class Cursor extends _$Cursor {
  var _sectionNumber = 0;
  var _stepNumber = 0;
  var _subStepNumber = 0;

  @override
  (Section, Step, SubStep) build() => ref.watch(configurationProvider).when(
        data: (configuration) {
          final section = configuration.sections.length > _sectionNumber
              ? configuration.sections[_sectionNumber]
              : Section(name: 'Empty', steps: [], displayStepNumber: 0);
          final step = section.steps.length > _stepNumber
              ? section.steps[_stepNumber]
              : Step(name: 'Empty');
          var subStep =
              step.subSteps != null && step.subSteps!.length > _subStepNumber
                  ? step.subSteps![_subStepNumber]
                  : SubStep(name: 'Empty', extentOffset: 0);
          return (section, step, subStep);
        },
        error: (error, stackTrace) => throw error,
        loading: () => (
          Section(name: 'Empty', steps: [], displayStepNumber: 0),
          Step(name: 'Empty', displayMarkdown: 'assets/empty.txt'),
          SubStep(name: 'Empty', extentOffset: 0)
        ),
      );

  void next() {
    final configuration = ref.read(configurationProvider).asData?.value;
    if (configuration == null) return;

    var sections = configuration.sections;
    final section = sections[_sectionNumber];
    var steps = section.steps;
    final step = steps[_stepNumber];
    final subSteps = step.subSteps;

    if (subSteps != null && subSteps.length > _subStepNumber + 1) {
      _subStepNumber++;
    } else if (steps.length > _stepNumber + 1) {
      _stepNumber++;
      _subStepNumber = 0;
    } else if (sections.length > _sectionNumber + 1) {
      _sectionNumber++;
      _stepNumber = 0;
      _subStepNumber = 0;
    }

    ref.invalidateSelf();
    return;
  }

  void previous() {
    final configuration = ref.read(configurationProvider).asData?.value;
    if (configuration == null) return;

    var sections = configuration.sections;
    final section = sections[_sectionNumber];
    var steps = section.steps;
    final step = steps[_stepNumber];
    final subSteps = step.subSteps;

    if (subSteps != null && _subStepNumber > 0) {
      _subStepNumber--;
    } else if (_stepNumber > 0) {
      _stepNumber--;
      var subSteps = section.steps[_stepNumber].subSteps;
      if (subSteps != null) {
        _subStepNumber = subSteps.length - 1;
      } else {
        _subStepNumber = 0;
      }
    } else if (_sectionNumber > 0) {
      _sectionNumber--;
      _stepNumber = sections[_sectionNumber].steps.length - 1;
      var subSteps = sections[_sectionNumber].steps[_stepNumber].subSteps;
      if (subSteps != null) {
        _subStepNumber = subSteps.length - 1;
      } else {
        _subStepNumber = 0;
      }
    }

    ref.invalidateSelf();
    return;
  }

  void setCursorPosition({
    required int sectionNumber,
    int stepNumber = 0,
    int subStepNumber = 0,
  }) {
    _sectionNumber = sectionNumber;
    _stepNumber = stepNumber;
    _subStepNumber = subStepNumber;
    ref.invalidateSelf();
  }
}

@riverpod
Future<Highlighters> highlighters(HighlightersRef ref) async {
  await Highlighter.initialize(['dart', 'yaml', 'json']);
  Highlighter.addLanguage('xml', xmlSyntax);
  Highlighter.addLanguage('glsl', glslSyntax);

  var theme = await HighlighterTheme.loadDarkTheme();
  return Highlighters(
    glsl: Highlighter(language: 'glsl', theme: theme),
    dart: Highlighter(language: 'dart', theme: theme),
    yaml: Highlighter(language: 'yaml', theme: theme),
    xml: Highlighter(language: 'xml', theme: theme),
    json: Highlighter(language: 'json', theme: theme),
  );
}

// From: https://github.com/microsoft/vscode-textmate/blob/main/test-cases/themes/syntaxes/xml.json
const xmlSyntax = r'''
{
	"scopeName": "text.xml",
	"name": "XML",
	"fileTypes": [
		"atom",
		"axml",
		"bpmn",
		"config",
		"cpt",
		"csl",
		"csproj",
		"csproj.user",
		"dae",
		"dia",
		"dita",
		"ditamap",
		"dtml",
		"fodg",
		"fodp",
		"fods",
		"fodt",
		"fsproj",
		"fxml",
		"glade",
		"gpx",
		"graphml",
		"icls",
		"iml",
		"isml",
		"jmx",
		"jsp",
		"launch",
		"menu",
		"mxml",
		"nuspec",
		"opml",
		"owl",
		"pom",
		"ppj",
		"proj",
		"pt",
		"pubxml",
		"pubxml.user",
		"rdf",
		"rng",
		"rss",
		"shproj",
		"storyboard",
		"svg",
		"targets",
		"tld",
		"vbox",
		"vbox-prev",
		"vbproj",
		"vbproj.user",
		"vcproj",
		"vcproj.filters",
		"vcxproj",
		"vcxproj.filters",
		"wsdl",
		"xaml",
		"xbl",
		"xib",
		"xlf",
		"xliff",
		"xml",
		"xpdl",
		"xsd",
		"xul",
		"ui"
	],
	"patterns": [
		{
			"begin": "(<\\?)\\s*([-_a-zA-Z0-9]+)",
			"captures": {
				"1": {
					"name": "punctuation.definition.tag.xml"
				},
				"2": {
					"name": "entity.name.tag.xml"
				}
			},
			"end": "(\\?>)",
			"name": "meta.tag.preprocessor.xml",
			"patterns": [
				{
					"match": " ([a-zA-Z-]+)",
					"name": "entity.other.attribute-name.xml"
				},
				{
					"include": "#doublequotedString"
				},
				{
					"include": "#singlequotedString"
				}
			]
		},
		{
			"begin": "(<!)(DOCTYPE)\\s+([:a-zA-Z_][:a-zA-Z0-9_.-]*)",
			"captures": {
				"1": {
					"name": "punctuation.definition.tag.xml"
				},
				"2": {
					"name": "keyword.other.doctype.xml"
				},
				"3": {
					"name": "variable.language.documentroot.xml"
				}
			},
			"end": "\\s*(>)",
			"name": "meta.tag.sgml.doctype.xml",
			"patterns": [
				{
					"include": "#internalSubset"
				}
			]
		},
		{
			"include": "#comments"
		},
		{
			"begin": "(<)((?:([-_a-zA-Z0-9]+)(:))?([-_a-zA-Z0-9:]+))(?=(\\s[^>]*)?></\\2>)",
			"beginCaptures": {
				"1": {
					"name": "punctuation.definition.tag.xml"
				},
				"2": {
					"name": "entity.name.tag.xml"
				},
				"3": {
					"name": "entity.name.tag.namespace.xml"
				},
				"4": {
					"name": "punctuation.separator.namespace.xml"
				},
				"5": {
					"name": "entity.name.tag.localname.xml"
				}
			},
			"end": "(>)(</)((?:([-_a-zA-Z0-9]+)(:))?([-_a-zA-Z0-9:]+))(>)",
			"endCaptures": {
				"1": {
					"name": "punctuation.definition.tag.xml"
				},
				"2": {
					"name": "punctuation.definition.tag.xml"
				},
				"3": {
					"name": "entity.name.tag.xml"
				},
				"4": {
					"name": "entity.name.tag.namespace.xml"
				},
				"5": {
					"name": "punctuation.separator.namespace.xml"
				},
				"6": {
					"name": "entity.name.tag.localname.xml"
				},
				"7": {
					"name": "punctuation.definition.tag.xml"
				}
			},
			"name": "meta.tag.no-content.xml",
			"patterns": [
				{
					"include": "#tagStuff"
				}
			]
		},
		{
			"begin": "(</?)(?:([-\\w\\.]+)((:)))?([-\\w\\.:]+)",
			"captures": {
				"1": {
					"name": "punctuation.definition.tag.xml"
				},
				"2": {
					"name": "entity.name.tag.namespace.xml"
				},
				"3": {
					"name": "entity.name.tag.xml"
				},
				"4": {
					"name": "punctuation.separator.namespace.xml"
				},
				"5": {
					"name": "entity.name.tag.localname.xml"
				}
			},
			"end": "(/?>)",
			"name": "meta.tag.xml",
			"patterns": [
				{
					"include": "#tagStuff"
				}
			]
		},
		{
			"include": "#entity"
		},
		{
			"include": "#bare-ampersand"
		},
		{
			"begin": "<%@",
			"beginCaptures": {
				"0": {
					"name": "punctuation.section.embedded.begin.xml"
				}
			},
			"end": "%>",
			"endCaptures": {
				"0": {
					"name": "punctuation.section.embedded.end.xml"
				}
			},
			"name": "source.java-props.embedded.xml",
			"patterns": [
				{
					"match": "page|include|taglib",
					"name": "keyword.other.page-props.xml"
				}
			]
		},
		{
			"begin": "<%[!=]?(?!--)",
			"beginCaptures": {
				"0": {
					"name": "punctuation.section.embedded.begin.xml"
				}
			},
			"end": "(?!--)%>",
			"endCaptures": {
				"0": {
					"name": "punctuation.section.embedded.end.xml"
				}
			},
			"name": "source.java.embedded.xml",
			"patterns": [
				{
					"include": "source.java"
				}
			]
		},
		{
			"begin": "<!\\[CDATA\\[",
			"beginCaptures": {
				"0": {
					"name": "punctuation.definition.string.begin.xml"
				}
			},
			"end": "]]>",
			"endCaptures": {
				"0": {
					"name": "punctuation.definition.string.end.xml"
				}
			},
			"name": "string.unquoted.cdata.xml"
		}
	],
	"repository": {
		"EntityDecl": {
			"begin": "(<!)(ENTITY)\\s+(%\\s+)?([:a-zA-Z_][:a-zA-Z0-9_.-]*)(\\s+(?:SYSTEM|PUBLIC)\\s+)?",
			"captures": {
				"1": {
					"name": "punctuation.definition.tag.xml"
				},
				"2": {
					"name": "keyword.other.entity.xml"
				},
				"3": {
					"name": "punctuation.definition.entity.xml"
				},
				"4": {
					"name": "variable.language.entity.xml"
				},
				"5": {
					"name": "keyword.other.entitytype.xml"
				}
			},
			"end": "(>)",
			"patterns": [
				{
					"include": "#doublequotedString"
				},
				{
					"include": "#singlequotedString"
				}
			]
		},
		"bare-ampersand": {
			"match": "&",
			"name": "invalid.illegal.bad-ampersand.xml"
		},
		"doublequotedString": {
			"begin": "\"",
			"beginCaptures": {
				"0": {
					"name": "punctuation.definition.string.begin.xml"
				}
			},
			"end": "\"",
			"endCaptures": {
				"0": {
					"name": "punctuation.definition.string.end.xml"
				}
			},
			"name": "string.quoted.double.xml",
			"patterns": [
				{
					"include": "#entity"
				},
				{
					"include": "#bare-ampersand"
				}
			]
		},
		"entity": {
			"captures": {
				"1": {
					"name": "punctuation.definition.constant.xml"
				},
				"3": {
					"name": "punctuation.definition.constant.xml"
				}
			},
			"match": "(&)([:a-zA-Z_][:a-zA-Z0-9_.-]*|#[0-9]+|#x[0-9a-fA-F]+)(;)",
			"name": "constant.character.entity.xml"
		},
		"internalSubset": {
			"begin": "(\\[)",
			"captures": {
				"1": {
					"name": "punctuation.definition.constant.xml"
				}
			},
			"end": "(\\])",
			"name": "meta.internalsubset.xml",
			"patterns": [
				{
					"include": "#EntityDecl"
				},
				{
					"include": "#parameterEntity"
				},
				{
					"include": "#comments"
				}
			]
		},
		"parameterEntity": {
			"captures": {
				"1": {
					"name": "punctuation.definition.constant.xml"
				},
				"3": {
					"name": "punctuation.definition.constant.xml"
				}
			},
			"match": "(%)([:a-zA-Z_][:a-zA-Z0-9_.-]*)(;)",
			"name": "constant.character.parameter-entity.xml"
		},
		"singlequotedString": {
			"begin": "'",
			"beginCaptures": {
				"0": {
					"name": "punctuation.definition.string.begin.xml"
				}
			},
			"end": "'",
			"endCaptures": {
				"0": {
					"name": "punctuation.definition.string.end.xml"
				}
			},
			"name": "string.quoted.single.xml",
			"patterns": [
				{
					"include": "#entity"
				},
				{
					"include": "#bare-ampersand"
				}
			]
		},
		"tagStuff": {
			"patterns": [
				{
					"captures": {
						"1": {
							"name": "entity.other.attribute-name.namespace.xml"
						},
						"2": {
							"name": "entity.other.attribute-name.xml"
						},
						"3": {
							"name": "punctuation.separator.namespace.xml"
						},
						"4": {
							"name": "entity.other.attribute-name.localname.xml"
						}
					},
					"match": "(?:^|\\s+)(?:([-\\w.]+)((:)))?([-\\w.:]+)="
				},
				{
					"include": "#doublequotedString"
				},
				{
					"include": "#singlequotedString"
				}
			]
		},
		"comments": {
			"begin": "<[!%]--",
			"captures": {
				"0": {
					"name": "punctuation.definition.comment.xml"
				}
			},
			"end": "--%?>",
			"name": "comment.block.xml"
		}
	},
	"version": "https://github.com/atom/language-xml/commit/f461d428fb87040cb8a52d87d0b95151b9d3c0cc"
}
''';

// From: https://github.com/GeForceLegend/vscode-glsl/blob/master/syntaxes/glsl.tmLanguage.json
const glslSyntax = r'''
{
	"name": "OpenGL Shading Language",
	"fileTypes": [
		"vs",
		"fs",
		"gs",
		"vsh",
		"fsh",
		"gsh",
		"csh",
		"vshader",
		"fshader",
		"gshader",
		"vert",
		"frag",
		"geom",
		"tesc",
		"tese",
		"comp",
		"glsl",
		"mesh",
		"task",
		"rgen",
		"rint",
		"rahit",
		"rchit",
		"rmiss",
		"rcall"
	],
	"patterns": [
		{
			"include": "#preprocessors"
		},
		{
			"include": "#comments"
		},
		{
			"include": "#blocks"
		},
		{
			"include": "#parens"
		},
		{
			"include": "#modifiers"
		},
		{
			"include": "#control_keywords"
		},
		{
			"include": "#reserved_keyword_for_future_use"
		},
		{
			"include": "#function_define"
		},
		{
			"include": "#function_call"
		},
		{
			"include": "#expressions"
		},
		{
			"include": "#function_builtin"
		},
		{
			"match": "}",
			"name": "invalid.illegal.stray-bracket-end.glsl"
		},
		{
			"match": "\\]",
			"name": "invalid.illegal.stray-bracket-end.glsl"
		},
		{
			"match": "\\)",
			"name": "invalid.illegal.stray-bracket-end.glsl"
		}
	],
	"repository": {
		"preprocessor_setting": {
			"match": "^\\s*(#\\s*(if|elif|undef|else|endif|pragma|line))\\b",
			"name": "keyword.control.preprocessor.glsl"
		},
		"preprocessor_version": {
			"match": "^\\s*(#\\s*version)\\s+([0-9]+\\s+)?(compatibility|core|es)?",
			"captures": {
				"1": {
					"name": "keyword.control.preprocessor.glsl"
				},
				"2": {
					"name": "constant.numeric.glsl"
				},
				"3": {
					"name": "variable.parameter.glsl"
				}
			}
		},
		"preprocessor_pragma": {
			"match": "^\\s*(#\\s*pragma)((\\s+[a-zA-Z_]\\w*)*)(\\s*\\(([a-zA-Z_]\\w*)\\))?",
			"captures": {
				"1": {
					"name": "keyword.control.preprocessor.glsl"
				},
				"2": {
					"name": "string.unquoted.pragma.glsl"
				},
				"5": {
					"name": "variable.parameter.glsl"
				}
			}
		},
		"preprocessor_line": {
			"match": "^\\s*(#\\s*line)(\\s+[+-]?[0-9]*)?(\\s+[+-]?[0-9]*)?",
			"captures": {
				"1": {
					"name": "keyword.control.preprocessor.glsl"
				},
				"2": {
					"name": "string.unquoted.line.glsl"
				},
				"3": {
					"name": "string.unquoted.line.glsl"
				}
			}
		},
		"preprocessor_import": {
			"match": "^\\s*(#\\s*(include|include_next|import|moj_import))\\s+(\"[^\\:*?\"<>|]*\"|<[^\\:*?\"<>|]*>)?",
			"captures": {
				"1": {
					"name": "keyword.control.import.glsl"
				},
				"3": {
					"name": "string.quoted.include.glsl"
				}
			}
		},
		"preprocessor_extension": {
			"match": "^\\s*(#\\s*extension)(\\s+[a-zA-Z_]\\w*)?(\\s*:\\s*(require|enable|warn|disable))?",
			"captures": {
				"1": {
					"name": "keyword.control.preprocessor.glsl"
				},
				"2": {
					"name": "string.unquoted.extension.glsl",
					"patterns": [
						{
							"match": "\\ball\\b",
							"name": "constant.language.glsl"
						}
					]
				},
				"4": {
					"name": "variable.parameter.glsl"
				}
			}
		},
		"preprocessor_error": {
			"match": "^\\s*(#\\s*error)(\\s+[^\\n]+)?(?=\\n)",
			"captures": {
				"1": {
					"name": "keyword.control.preprocessor.glsl"
				},
				"2": {
					"name": "string.unquoted.error.glsl"
				}
			}
		},
		"preprocessor_define_function": {
			"begin": "^\\s*(#\\s*define)\\s+([a-zA-Z_]\\w*)\\(",
			"end": "\\)",
			"beginCaptures": {
				"1": {
					"name": "keyword.control.preprocessor.glsl"
				},
				"2": {
					"name": "entity.name.function.glsl"
				}
			},
			"patterns": [
				{
					"include": "#comments"
				},
				{
					"match": "\\b([a-zA-Z_]\\w*)\\b",
					"name": "variable.parameter.glsl"
				}
			]
		},
		"preprocessor_define_variable": {
			"match": "^\\s*(#\\s*define)(\\s+[a-zA-Z_]\\w*)?",
			"captures": {
				"1": {
					"name": "keyword.control.preprocessor.glsl"
				},
				"2": {
					"name": "entity.name.function.glsl"
				}
			}
		},
		"preprocessor_define_setting": {
			"patterns": [
				{
					"begin": "^\\s*(#\\s*if|#\\s*elif)\\b",
					"end": "\\n",
					"beginCaptures": {
						"1": {
							"name": "keyword.control.preprocessor.glsl"
						}
					},
					"patterns": [
						{
							"include": "#comments"
						},
						{
							"match": "\\b(\\!)?defined\\b",
							"name": "keyword.control.preprocessor.glsl"
						},
						{
							"match": "\\b[a-zA-Z_]\\w*",
							"name": "entity.name.function.glsl"
						},
						{
							"include": "#expressions"
						}
					]
				},
				{
					"match": "^\\s*(#\\s*(ifdef|ifndef|if|elif)\\b)\\s+([a-zA-Z_]\\w*)?",
					"captures": {
						"1": {
							"name": "keyword.control.preprocessor.glsl"
						},
						"3": {
							"name": "entity.name.function.glsl"
						}
					}
				}
			]
		},
		"preprocessor_undefine": {
			"match": "^\\s*(#\\s*undef)\\s+([a-zA-Z_]\\w*)?",
			"captures": {
				"1": {
					"name": "keyword.control.preprocessor.glsl"
				},
				"2": {
					"name": "entity.name.function.glsl"
				}
			}
		},
		"preprocessor_minecraft_setting": {
			"match": "^/\\*[ ](SHADOWRES|SHADOWFOV|SHADOWHPL|WETNESSHL|DRYNESSHL|GAUX[0-9]FORMAT|DRAWBUFFERS):([0-9a-zA-Z.]+)[ ]\\*/\\n",
			"captures": {
				"1": {
					"name": "variable.language.glsl"
				},
				"2": {
					"name": "constant.character.glsl"
				}
			}
		},
		"preprocessor_minecraft_layout_new": {
			"match": "^/\\*[ ](RENDERTARGETS):[ ]([0-9,]+)[ ]\\*/\\n",
			"captures": {
				"1": {
					"name": "variable.language.glsl"
				},
				"2": {
					"patterns": [
						{
							"match": "[0-9]+",
							"name": "constant.numeric.glsl"
						}
					]
				}
			}
		},
		"preprocessors": {
			"patterns": [
				{
					"include": "#preprocessor_define_function"
				},
				{
					"include": "#preprocessor_define_variable"
				},
				{
					"include": "#preprocessor_define_setting"
				},
				{
					"include": "#preprocessor_undefine"
				},
				{
					"include": "#preprocessor_version"
				},
				{
					"include": "#preprocessor_pragma"
				},
				{
					"include": "#preprocessor_line"
				},
				{
					"include": "#preprocessor_import"
				},
				{
					"include": "#preprocessor_extension"
				},
				{
					"include": "#preprocessor_error"
				},
				{
					"include": "#preprocessor_setting"
				},
				{
					"include": "#preprocessor_minecraft_setting"
				},
				{
					"include": "#preprocessor_minecraft_layout_new"
				}
			]
		},
		"comments": {
			"patterns": [
				{
					"match": "^/\\* =(\\s*.*?)\\s*= \\*/$\\n",
					"name": "comment.block.glsl",
					"captures": {
						"1": {
							"name": "meta.toc-list.banner.block.glsl"
						}
					}
				},
				{
					"begin": "/\\*",
					"end": "\\*/",
					"beginCaptures": {
						"1": {
							"name": "punctuation.definition.comment.block.begin.glsl"
						}
					},
					"endCaptures": {
						"1": {
							"name": "punctuation.definition.comment.block.end.glsl"
						}
					},
					"name": "comment.block.glsl"
				},
				{
					"match": "\\*/(?!\\*)",
					"name": "invalid.illegal.stray-comment-end.glsl"
				},
				{
					"match": "^// =(\\s*.*?)\\s*=\\s*$\\n?",
					"name": "comment.line.banner.glsl",
					"captures": {
						"1": {
							"name": "meta.toc-list.banner.line.glsl"
						}
					}
				},
				{
					"begin": "//",
					"end": "(?<!\\\\)$(?=\\n)",
					"beginCaptures": {
						"1": {
							"name": "punctuation.definition.comment.glsl"
						}
					},
					"name": "comment.line.double-slash.glsl"
				}
			]
		},
		"before_tag": {
			"match": "\\bstruct\\b",
			"name": "storage.type.glsl"
		},
		"control_keywords": {
			"patterns": [
				{
					"match": "\\b(break|case|continue|default|discard|do|else|for|if|return|switch|while)\\b",
					"name": "keyword.control.glsl"
				},
				{
					"match": "\\b(demote|ignoreIntersectionEXT|terminateInvocation|terminateRayEXT)\\b",
					"name": "keyword.control.glsl"
				}
			]
		},
		"reserved_keyword_for_future_use": {
			"match": "\\b(?:common|partition|active|asm|class|union|enum|typedef|template|this|resource|goto|inline|noinline|public|static|extern|external|interface|long|short|half|fixed|unsigned|superp|input|output|[fh]vec[2-4]|sampler3DRect|filter|sizeof|cast|namespace|using)\\b",
			"name": "invalid.illegal.reserved-keyword.glsl"
		},
		"macros": {
			"match": "\\b(__(LINE|FILE|VERSION)__|GL_(core|es|compatibility)_profile)\\b",
			"name": "constant.macro.predefined.glsl"
		},
		"modifiers": {
			"patterns": [
				{
					"match": "\\b(atomic_uint|attribute|buffer|centroid|coherent|const|flat|highp|in|inout|invariant|layout|lowp|mediump|noperspective|out|patch|precise|precision|readonly|restrict|sample|shared|smooth|subroutine|uniform|varying|volatile|writeonly)\\b",
					"name": "storage.modifier.glsl"
				},
				{
					"match": "\\b((callableData|rayPayload)(In)?(EXT|NV)|hitAttribute(EXT|NV)|hitObjectAttributeNV|nonuniformEXT|perprimitive(EXT|NV)|pervertex(EXT|NV)|perviewNV|subgroupuniformEXT|taskPayloadSharedEXT|taskNV|tileImageEXT)\\b",
					"name": "storage.modifier.glsl"
				}
			]
		},
		"variables": {
			"patterns": [
				{
					"match": "\\bgl_(Base(Instance|Vertex)|(Back|Front)((Secondary)?Color|Light(Model)?Product|Material)|Clip(Distance|Plane|Vertex)|CullDistance|Color|DepthRange(Parameters)?|DrawID|EyePlane[QRST]|Fog(((Frag)?Coord)?|Parameters)|Frag(Color|Coord|Data|Depth)|FrontFacing|(Global)?InvocationID|HelperInvocation|in|(Instance|LocalInvocation)(ID|Index)|Layer|Light(Model|Source)(Parameters)?|Light(Model)?Products|MaterialParameters|(ModelView(Projection)?|Projection|Texture)Matrix(Inverse)?(Transpose)?|MultiTexCoord[0-7]|NumWorkGroups|Normal(Matrix|Scale)?|out|ObjectPlane[QRST]|PatchVerticesIn|Per(Fragment|Vertex)|Point(Coord|Parameters|Size)?|Position|PrimitiveID(In)?|Sample(ID|Mask(In)?|Position)|SecondaryColor|Tess(Coord|Level(Inner|Outer))|TexCoord|TextureEnvColor|Vertex(ID|Index)?|ViewportIndex|WorkGroup(ID|Size))\\b",
					"name": "variable.language.glsl"
				},
				{
					"match": "\\bgl_(BaryCoord(NoPersp)?(EXT|NV)|Core(Count|ID|Max)ARM|CullMaskEXT|CurrentRayTimeNV|DeviceIndex|FragInvocationCountEXT|FragSizeEXT|FragmentSizeNV|GeometryIndexEXT|HitKind(Back|Front)FacingMicroTriangleNV|Hit(Kind|T)(EXT|NV)|(IncomingRayFlags|InstanceCustomIndex)(EXT|NV)|Launch(ID|Size)(EXT|NV)|MeshViewCountNV|Num(Samples|Subgroups)|ObjectRay(Direction|Origin)(EXT|NV)|ObjectToWorld((3x4)?EXT|NV)|RayT(max|min)(EXT|NV)|SMCountNV|SMIDNV|Subgroup((Eq|[GL][et])Mask|(Invocation)?ID|Size)|TaskCountNV|ViewIndex|WarpID(ARM|NV)|Warp(MaxIDARM|sPerSMNV)|WorldRay(Direction|Origin)(EXT|NV)|WorldToObject((3x4)?EXT|NV))\\b",
					"name": "variable.language.glsl"
				}
			]
		},
		"constants": {
			"patterns": [
				{
					"match": "\\bgl_(Max((Combined|Compute|Fragment|Geometry|TessControl|TessEvaluation|Vertex)(AtomicCounter(Buffer)?|ImageUniforms)s|(Combined|Compute|Geometry|TessControl|TessEvaluation|Vertex)?TextureImageUnits|(Compute|Fragment|Geometry|TessControl|TessEvaluation|Vertex)UniformComponents|((Geometry|TessControl)(Total)?|TessEvaluation|Vertex)OutputComponents|(Fragment|Vertex)UniformVectors|(Fragment|Geometry|TessControl|TessEvaluation)InputComponents|AtomicCounter(Bindings|BufferSize)|Clip(Distances|Planes)|(CombinedClipAnd)?CullDistances|Combined(ImageUnitsAndFragmentOutputs|ShaderOutputResources)|ComputeWorkGroup(Count|Size)|DrawBuffers|GeometryOutputVertices|(Geometry)?VaryingComponents|Image(Samples|Units)|InputAttachments|Lights|PatchVertices|ProgramTexelOffset|Samples|Tess(GenLevel|PatchComponents)|Texture(Coords|Units)|TransformFeedback(Buffers|InterleavedComponents)|Varying(Floats|Vectors)|VertexAttribs|Viewports)|MinProgramTexelOffset)\\b",
					"name": "support.constant.glsl"
				},
				{
					"match": "\\bgl_(CooperativeMatrixLayout(Row|Column)Major|HitKind(Back|Front)FacingTriangleEXT|Matrix(Use([AB]|Accumulator)|OperandsSaturatingAccumulation)|MaxMeshViewCountNV|RayFlags(Cull(Back|Front)FacingTriangles|(Cull)?(No)?Opaque|None|kipClosestHitShader|TerminateOnFirstHit)(EXT|NV)|RayFlags(ForceOpacityMicromap2State|SkipAABBSkipTriangles)EXT|RayQuery(CandidateIntersection(AABB|Triangle)|CommittedIntersection(Generated|None|Triangle))EXT|Scope(Device|Invocation|QueueFamily|Subgroup|Workgroup)|Semantics(Acquire|Make(Available|Visible)|Relaxed|Release|Volatile)|ShadingRateFlag[24](Horizontal|Vertical)PixelsEXT|StorageSemantics(Buffer|Image|None|Output|Shared))\\b",
					"name": "support.constant.glsl"
				}
			]
		},
		"reserved_name_for_future_use": {
			"match": "\\bgl_\\w*\\b",
			"name": "invalid.illegal.reserved-vadiable.glsl"
		},
		"types": {
			"patterns": [
				{
					"match": "\\b(void|bool|u?int|float|double|[dbiu]?vec[2-4]|d?mat[2-4](x[2-4])?|[iu]?(sampler|image)(1D(Array)?|2D(MS)?(Array)?|2DRect|3D|Cube(Array)?|Buffer)|sampler((([12]D|Cube)(Array)?|2DRect)?Shadow)?|[iu]?texture([12]D(Array)?|2D(Rect|MS(Array)?)|3D|Cube(Array)?|Buffer)|[iu]?subpassInput(MS)?)\\b",
					"name": "storage.type.glsl"
				},
				{
					"match": "\\b(float(16|32|64)_t|f(16|32|64)(vec[2-4]|mat[2-4](x[2-4])?)|u?int(8|16|32|64)_t|[iu](8|16|32|64)vec[2-4]|accelerationStructure(EXT|NV)|hitObjectNV|rayQueryEXT|[iu]64image(1D(Array)?|2D(Rect|(MS)?(Array)?)|3D|Cube(Array)?|Buffer)|[iu]?attachmentEXT|[fui]coopmatNV|coopmat)\\b",
					"name": "storage.type.glsl"
				}
			]
		},
		"numbers": {
			"match": "\\b((0(x|X)[0-9a-fA-F]*(\\.[0-9a-fA-F]+p-?\\d+)?)|(([0-9]+\\.?[0-9]*)|(\\.[0-9]+))((e|E)(\\+|-)?[0-9]+)?)([fF]|(l{1,2}|L{1,2})[uU]?|[uU](l{0,2}|L{0,2})|[lL][fF])?\\b",
			"name": "constant.numeric.glsl"
		},
		"booleans": {
			"match": "\\b(false|FALSE|NULL|true|TRUE)\\b",
			"name": "constant.language.glsl"
		},
		"operators": {
			"patterns": [
				{
					"match": "\\+\\=|-\\=|\\*\\=|/\\=|%\\=|&\\=|\\|\\=|\\^\\=|>>\\=|<<\\=",
					"name": "keyword.operator.assignment.augmented.glsl"
				},
				{
					"match": "\\+|\\-|\\*|/|%|<<|>>|&&|&|\\|\\||\\||\\^|~|!",
					"name": "keyword.operator.arithmetic.glsl"
				},
				{
					"match": "<\\=|>\\=|\\=\\=|<|>|\\!\\=|\\?|\\:",
					"name": "keyword.operator.comparison.glsl"
				},
				{
					"match": "\\=",
					"name": "keyword.operator.assignment.glsl"
				}
			]
		},
		"indexes": {
			"match": "(?<=\\.)([rgba]{1,4}|[xyzw]{1,4}|[stpq]{1,4})\\b",
			"name": "string.interpolated.indexes.glsl"
		},
		"index": {
			"begin": "\\[",
			"end": "\\]",
			"patterns": [
				{
					"include": "#preprocessors"
				},
				{
					"include": "#comments"
				},
				{
					"include": "#parens"
				},
				{
					"include": "#control_keywords"
				},
				{
					"include": "#reserved_keyword_for_future_use"
				},
				{
					"include": "#function_call"
				},
				{
					"include": "#expressions"
				},
				{
					"include": "#function_builtin"
				},
				{
					"include": "#illegal_brackets"
				},
				{
					"match": "\\)",
					"name": "invalid.illegal.stray-bracket-end.glsl"
				}
			]
		},
		"expressions": {
			"patterns": [
				{
					"include": "#control_keywords"
				},
				{
					"include": "#reserved_keyword_for_future_use"
				},
				{
					"include": "#before_tag"
				},
				{
					"include": "#macros"
				},
				{
					"include": "#modifiers"
				},
				{
					"include": "#variables"
				},
				{
					"include": "#constants"
				},
				{
					"include": "#reserved_name_for_future_use"
				},
				{
					"include": "#types"
				},
				{
					"include": "#numbers"
				},
				{
					"include": "#booleans"
				},
				{
					"include": "#operators"
				},
				{
					"include": "#indexes"
				},
				{
					"include": "#index"
				}
			]
		},
		"function_builtin": {
			"patterns": [
				{
					"match": "\\b(abs|a?cosh?|all(Invocations(Equal)?)?|any(Invocation)?|a?sinh?|a?tanh?|(atomic(Counter)?|imageAtomic)(Add|And|CompSwap|Exchange|Max|Min|Or|Xor)|atomicCounter(Decrement|Increment|Subtract)?|barrier|bit(Count|field(Extract|Insert|Reverse))|ceil|clamp|cross|degrees|determinant|dFd[xy](Coarse|Fine)?|distance|dot|Emit(Stream)?Vertex|End(Stream)?Primitive|equal|exp2?|faceforward|find[LM]SB|floatBitsTo(Ui|I)nt|floor|fma|fract|frexp|ftransform|fwidth(Coarse|Fine)?|((greater|less)Than|not)(Equal)?|groupMemoryBarrier|image(Load|Samples|Size|Store)|[iu]mulExtended|u?intBitsToFloat|interpolateAt(Centroid|Offset|Sample)|inverse(sqrt)?|is(inf|nan)|ldexp|length|log2?|matrixCompMult|max|mi[nx]|memoryBarrier(AtomicCounter|Buffer|Image|Shared)?|modf?|noise[1-4]|normalize|outerProduct|(un)?pack(Double2x32|Half2x16|[SU]norm(2x16|4x8))|pow|radians|reflect|refract|round(Even)|shadow[12]D(Proj)?(Lod)?|sign|smoothstep|sqrt|step|subpassLoad|texelFetch(Offset)?|texture([1-3]D(Proj)?(Lod)?|Cube(Lod)?|Gather(Offsets?)?|(Proj)?(Grad|Lod)?(Offset)?|Query(Levels|Lod)|Samples|Size)|transpose|trunc|uaddCarry|usubBorrow)\\b",
					"name": "support.function.glsl"
				},
				{
					"match": "\\b(EmitMeshTasksEXT|atomic(Load|Store)|clockRealtime(2x32)?EXT|colorAttachmentReadEXT|computeDir|controlBarrier|doubleBitsTo(Ui|I)nt64|executeCallableNV|fetchMicroTriangleVertex(Barycentric|Position)NV|(float16|half)BitsTo(Ui|I)nt16|fragment(Mask)?FetchAMD|hitObject(ExecuteShader|Get(Attributes|CurrentTime|(Geometry|Primitive)Index|HitKind|Instance(CustomIndex|Id)|Object(Ray(Direction|Origin)|ToWorld)|RayT(Max|Min)|Shader(BindingTableRecordIndex|RecordBufferHandle)|World(Ray(Direction|Origin)|ToObject))|Is(Empty|Hit|Miss)|Record(Empty|(Hit(WithIndex)?|Miss)(Motion)?)|TraceRay(Motion)?)NV|ignoreIntersectionNV|[iu]nt16BitsTo(Float16|Half)|[iu]nt64BitsToDouble|pack(16|32|64|(Float|Uint)2x16|(Ui|I)nt2x32|Uint4x16)|rayQuery((Confirm|Generate)Intersection|GetIntersection(Barycentrics|CandidateAABBOpaque|FrontFace|(Geometry|Primitive)Index|Instance(CustomIndex|Id|ShaderBindingTableRecordOffset)|Object(Ray(Direction|Origin)|ToWorld)|T|TriangleVertexPositions|Type|WorldToObject)|Get(Ray(Flags|TMin)|WorldRay(Direction|Origin))|Initialize|Proceed|Terminate)EXT|reorderThreadNV|reportIntersection(EXT|NV)|subgroup(All(Equal)?|Any|Ballot((Exclusive|Inclusive)?BitCount|BitExtract|Find[LM]SB)?|Barrier|Broadcast(First)?|(Clustered|Exclusive|Inclusive)?(Add|And|Max|Min|Mul|Or|Xor)|Elect|InverseBallot|MemoryBarrier(Buffer|Image|Shared)?|PartitionNV|Partitioned(Exclusive|Inclusive)?(Add|And|Max|Min|Mul|Or|Xor)NV|Quad(Broadcast|Swap(Diagonal|Horizontal|Vertical))|Shuffle(Down|Up|Xor)?)|terminateRayNV|texture(BlockMatchS[AS]D|BoxFilter|Weighted)QCOM|trace(NV|Ray(EXT|MotionNV))|unpack(8|16|32|(Float|Uint)2x16|(Ui|I)nt2x32|Uint4x16)|writePackedPrimitiveIndices4x8NV)\\b",
					"name": "support.function.glsl"
				}
			]
		},
		"function_define": {
			"begin": "\\b([a-zA-Z_][0-9a-zA-Z]*)(?:\\[(?:([0-9]*)|(?:[a-zA-Z_]\\w*))?\\])?\\s+([a-zA-Z_]\\w*)\\s*\\(",
			"end": "\\)",
			"beginCaptures": {
				"1": {
					"patterns": [
						{
							"include": "#types"
						},
						{
							"match": "\\b(else|if)\\b",
							"name": "keyword.control.glsl"
						}
					]
				},
				"2": {
					"name": "constant.numeric.glsl"
				},
				"3": {
					"name": "entity.name.function.glsl",
					"patterns": [
						{
							"match": "\\bif\\b",
							"name": "keyword.control.glsl"
						}
					]
				}
			},
			"patterns": [
				{
					"include": "#preprocessors"
				},
				{
					"include": "#comments"
				},
				{
					"match": "\\b(?:(const)\\s+)?(?:(inout|out|in)\\s+)?(?:(highp|mediump|lowp)\\s+)?([a-zA-Z_]\\w*)(?:\\[(?:([0-9]+)|(?:[a-zA-Z_]\\w*))?\\])?(?:\\s+([a-zA-Z_]\\w*\\b)(?:\\[(\\w*)\\])?)?(?=\\s*(\\)|,))",
					"captures": {
						"1": {
							"name": "storage.modifier.glsl"
						},
						"2": {
							"name": "storage.modifier.glsl"
						},
						"3": {
							"name": "storage.modifier.glsl"
						},
						"4": {
							"patterns": [
								{
									"include": "#types"
								},
								{
									"match": "\\b(const|in|out|inout|highp|mediump|lowp)\\b",
									"name": "storage.modifier.glsl"
								}
							]
						},
						"5": {
							"name": "constant.numeric.glsl"
						},
						"6": {
							"name": "variable.parameter.glsl"
						},
						"7": {
							"patterns": [
								{
									"match": "\\b[0-9]+\\b",
									"name": "constant.numeric.glsl"
								}
							]
						}
					}
				},
				{
					"match": "\\b(in|out|inout|const|highp|mediump|lowp)\\b",
					"name": "storage.modifier.glsl"
				},
				{
					"include": "#types"
				},
				{
					"include": "#index"
				},
				{
					"match": "\\b([a-zA-Z_]\\w*)\\s+([a-zA-Z_]\\w*)\\b",
					"captures": {
						"2": {
							"name": "variable.parameter.glsl"
						}
					}
				},
				{
					"match": "\\b[a-zA-Z_]\\w*\\b",
					"name": "variable.parameter.glsl"
				},
				{
					"include": "#illegal_brackets"
				},
				{
					"match": "\\]",
					"name": "invalid.illegal.stray-bracket-end.glsl"
				},
				{
					"begin": "\\(",
					"end": "\\)",
					"name": "invalid.illegal.bracket.glsl"
				}
			]
		},
		"function_call": {
			"begin": "\\b([a-zA-Z_]\\w*)\\s*\\(",
			"end": "\\)",
			"beginCaptures": {
				"1": {
					"name": "support.function.glsl",
					"patterns": [
						{
							"match": "\\b(break|case|continue|default|discard|do|else|for|if|return|swich|while|layout)\\b",
							"name": "keyword.control.glsl"
						},
						{
							"match": "\\b(void|bool|u?int|float|double|[dbiu]?vec[2-4]|d?mat[2-4](x[2-4])?|[iu]?(sampler|image)(1D(Array)?|2D(MS)?(Array)?|2DRect|3D|Cube(Array)?|Buffer)|sampler((([12]D|Cube)(Array)?|2DRect)?Shadow)?|[iu]?texture([12]DArray|2D(Rect|MS(Array)?)|CubeArray|Buffer)|[iu]?subpassInput(MS)?)\\b",
							"name": "storage.type.glsl"
						}
					]
				}
			},
			"patterns": [
				{
					"include": "#preprocessors"
				},
				{
					"include": "#comments"
				},
				{
					"include": "#parens"
				},
				{
					"include": "#control_keywords"
				},
				{
					"include": "#reserved_keyword_for_future_use"
				},
				{
					"include": "#function_call"
				},
				{
					"include": "#expressions"
				},
				{
					"include": "#function_builtin"
				},
				{
					"include": "#illegal_brackets"
				},
				{
					"match": "\\]",
					"name": "invalid.illegal.stray-bracket-end.glsl"
				}
			]
		},
		"illegal_brackets": {
			"patterns": [
				{
					"begin": "{",
					"end": "}",
					"name": "invalid.illegal.bracket.glsl"
				},
				{
					"match": "}",
					"name": "invalid.illegal.bracket.glsl"
				}
			]
		},
		"blocks": {
			"begin": "{",
			"end": "}",
			"patterns": [
				{
					"include": "#preprocessors"
				},
				{
					"include": "#comments"
				},
				{
					"include": "#blocks"
				},
				{
					"include": "#parens"
				},
				{
					"include": "#control_keywords"
				},
				{
					"include": "#reserved_keyword_for_future_use"
				},
				{
					"include": "#function_call"
				},
				{
					"include": "#expressions"
				},
				{
					"include": "#function_builtin"
				},
				{
					"match": "\\)",
					"name": "invalid.illegal.stray-comment-end.glsl"
				},
				{
					"match": "\\]",
					"name": "invalid.illegal.stray-bracket-end.glsl"
				}
			]
		},
		"parens": {
			"begin": "\\(",
			"end": "\\)",
			"patterns": [
				{
					"include": "#preprocessors"
				},
				{
					"include": "#comments"
				},
				{
					"include": "#parens"
				},
				{
					"include": "#control_keywords"
				},
				{
					"include": "#reserved_keyword_for_future_use"
				},
				{
					"include": "#function_call"
				},
				{
					"include": "#expressions"
				},
				{
					"include": "#function_builtin"
				},
				{
					"include": "#illegal_brackets"
				},
				{
					"match": "\\]",
					"name": "invalid.illegal.stray-bracket-end.glsl"
				}
			]
		}
	},
	"scopeName": "source.glsl"
}
''';
