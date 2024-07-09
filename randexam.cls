% -*- coding: utf-8 -*-
% ----------------------------------------------------------------------------
% Author:  Jianrui Lyu <tolvjr@163.com>
% Package: https://ctan.org/pkg/randexam
% License: The LaTeX Project Public License 1.3c
% ----------------------------------------------------------------------------

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{randexam}[2024-07-09 v2024F Make an exam paper and its randomized variants]

%% Old LaTeX release could not recognize date format like 2022-11-01
%\@ifl@t@r\fmtversion{2022-11-01}{}{
\@ifl@t@r\fmtversion{2022/11/01}{}{
  \ClassError{randexam}{%
    Your current TeX distribution is quite old.\MessageBreak
    We need TeXLive 2023+ or MiKTeX 2023+ or CTeX 3.0+%
  }{Please update your TeX distribution first.}
}

%% ---------------------------------------------------------------------------
%% Start ignoring spaces in the code
%% ---------------------------------------------------------------------------

\RequirePackage{functional}
\IgnoreSpacesOn

%% ---------------------------------------------------------------------------
%% Boolean commands for this class
%% ---------------------------------------------------------------------------

\RequirePackage{etoolbox}

\NewDocumentCommand\NewExamBool{m}{
  \newbool{exam@#1}
}

\NewDocumentCommand\SetExamBoolTrue{m}{
  \booltrue{exam@#1}
}

\NewDocumentCommand\SetExamBoolFalse{m}{
  \boolfalse{exam@#1}
}

\NewExpandableDocumentCommand\IfExamBoolT{m+m}{
  \ifbool{exam@#1}{#2}{}
}

\NewExpandableDocumentCommand\IfExamBoolF{m+m}{
  \ifbool{exam@#1}{}{#2}
}

\NewExpandableDocumentCommand\IfExamBoolTF{m+m+m}{
  \ifbool{exam@#1}{#2}{#3}
}

%% ---------------------------------------------------------------------------
%% Declare language commands
%% ---------------------------------------------------------------------------

\tlSet\l@rdxm@current@language@tl{english}

\NewExpandableDocumentCommand\IfExamLanguageEqT{m+m}{
  \ExpandArgs{V}\ifstrequal\l@rdxm@current@language@tl{#1}{#2}{}
}

\NewExpandableDocumentCommand\IfExamLanguageEqF{m+m}{
  \ExpandArgs{V}\ifstrequal\l@rdxm@current@language@tl{#1}{}{#2}
}

\NewExpandableDocumentCommand\IfExamLanguageEqTF{m+m+m}{
  \ExpandArgs{V}\ifstrequal\l@rdxm@current@language@tl{#1}{#2}{#3}
}

%% ---------------------------------------------------------------------------
%% Declare class options
%% ---------------------------------------------------------------------------

\NewExamBool{plain}      \SetExamBoolFalse{plain}      % use plain page style
\NewExamBool{twoinone}   \SetExamBoolFalse{twoinone}   % use A3 paper
\NewExamBool{oneside}    \SetExamBoolFalse{oneside}    % use single sided exam paper
\NewExamBool{resetnumber}\SetExamBoolTrue{resetnumber} % reset numbers in new exam parts
\NewExamBool{random}     \SetExamBoolFalse{random}     % shuffle questions
\NewExamBool{answer}     \SetExamBoolTrue{answer}      % show answers
\NewExamBool{evaluator}  \SetExamBoolFalse{evaluator}  % add evaluator line in the grade table
\NewExamBool{mathdesign} \SetExamBoolTrue{mathdesign}  % use mathdesign fonts
\NewExamBool{freealign}  \SetExamBoolFalse{freealign}  % load freealign package
\NewExamBool{medmath}    \SetExamBoolFalse{medmath}    % use medium-size formulas
\NewExamBool{moremath}   \SetExamBoolFalse{moremath}   % define more math commands

\DeclareKeys[randexam]{
   language   .store     = \l@rdxm@current@language@tl
  ,plain      .if        = exam@plain
  ,a3paper    .if        = exam@twoinone
  ,a3input    .code      = \SetExamBoolTrue{twoinone}\SetExamBoolTrue{plain}
  ,oneside    .if        = exam@oneside
  ,random     .if        = exam@random
  ,noanswer   .ifnot     = exam@answer
  ,evaluator  .if        = exam@evaluator
  ,mathdesign .if        = exam@mathdesign
  ,freealign  .if        = exam@freealign
  ,medmath    .if        = exam@medmath
  ,moremath   .if        = exam@moremath
  ,math       .choice:
  ,math       .default:n = many
  ,math/many  .code      = \SetExamBoolTrue{mathdesign}\SetExamBoolTrue{freealign}
  ,math/most  .code      = \SetExamBoolTrue{mathdesign}\SetExamBoolTrue{freealign}
                           \SetExamBoolTrue{medmath}
  ,math/all   .code      = \SetExamBoolTrue{mathdesign}\SetExamBoolTrue{freealign}
                           \SetExamBoolTrue{medmath}\SetExamBoolTrue{moremath}
}

%% Support for Chinese language
\NewExamBool{ctex}     \SetExamBoolFalse{ctex}      % load ctex package
\NewExamBool{solidot}  \SetExamBoolFalse{solidot}   % use full-width solid periods
\NewExamBool{sourcehan}\SetExamBoolFalse{sourcehan} % use source han font
\DeclareKeys[randexam]{
   ctex         .if        = exam@ctex
  ,solidot      .if        = exam@solidot
  ,sourcehan    .if        = exam@sourcehan
  ,chinese      .choice:
  ,chinese      .default:n = many
  ,chinese/many .code      = \SetExamBoolTrue{ctex}
  ,chinese/most .code      = \SetExamBoolTrue{ctex}\SetExamBoolTrue{solidot}
  ,chinese/all  .code      = \SetExamBoolTrue{ctex}\SetExamBoolTrue{solidot}\SetExamBoolTrue{sourcehan}
}

\DeclareUnknownKeyHandler{\PassOptionsToClass{\CurrentOption}{article}}

\ProcessKeyOptions

\LoadClass{article}

%% Avoid option conflicts with fontspec package
%% see https://github.com/latex3/fontspec/issues/501
\let\@raw@classoptionslist\@empty

\IfExamBoolTF{twoinone}{
  \RequirePackage[a3paper,landscape,twocolumn,columnsep=60mm,left=30mm,right=30mm,top=25mm,bottom=25mm]{geometry}
}{
  \RequirePackage[a4paper,left=30mm,right=30mm,top=25mm,bottom=25mm]{geometry}
}

\geometry{headheight=17pt}

\RequirePackage{amsmath}
\RequirePackage{array}
\RequirePackage{calc}
\RequirePackage{comment}
\RequirePackage[inline]{enumitem}
\RequirePackage{environ}
\RequirePackage{fancyhdr}
\RequirePackage{zref-user,zref-lastpage}
\RequirePackage{tabularx}
\RequirePackage{xcolor}
\RequirePackage{tabularray}
\UseTblrLibrary{diagbox}

\IfExamBoolT{plain}{\allowdisplaybreaks[4]}

\IfExamBoolT{twoinone}{
  \RequirePackage{pdfpages}
  % When pdfpages package is newer enough, putting \includepdf at the beginning
  % of document body will cause an error about an undefined command;
  % see https://tex.stackexchange.com/questions/352007/ieeetran-and-pdfpages
  % Also since LaTeX release 2018-04-01 \@ifundefined won't turn an undefined command
  % into \relax; see https://www.latex-project.org/news/latex2e-news/ltnews28.pdf
  \@ifundefined{@setmarks}{\let\@setmarks\relax}{}
}

\IfExamBoolTF{mathdesign}{
  \RequirePackage[utopia]{mathdesign} % charter, utopia
  \renewcommand\bfdefault{bx}
  \let\oldoiint\oiint\renewcommand{\oiint}{\oldoiint\nolimits}
  \DeclareTextCommandDefault{\nobreakspace}{\leavevmode\nobreak\ }
}{
  \RequirePackage{amssymb}
}

\setlength\arraycolsep{4pt}
\newcolumntype{Y}{>{\centering\arraybackslash}X}
\newcolumntype{n}[1]{>{\centering\arraybackslash}m{#1}}

\setlength{\parindent}{0em}
\setlength{\lineskiplimit}{4pt}
\setlength{\lineskip}{4pt}

\NewDocumentCommand\SetExamOption{+m}{\SetKeys[randexam]{#1}}

%% ---------------------------------------------------------------------------
%% Template commands for exam elements
%% ---------------------------------------------------------------------------

%% #1: exam element; #2: template name; #3: template code
%% If the template name = default, we enable the template at once
%% Otherwise, we may enable the template by using \SelectExamTemplate command
\NewDocumentCommand\DeclareExamTemplate{mm+m}{
  \tlSet{\expName{l@rdxm@template@#1@#2@tl}}{#3}
}

%% #1: exam element; #2: template name
\NewDocumentCommand\SelectExamTemplate{mm}{
  \tlSetEq{\expName{l@rdxm@template@#1@default@tl}}{\expName{l@rdxm@template@#1@#2@tl}}
}

%% #1: exam element; #2: template name.
%% In an expandable command, we should use \UseName but not \expName.
\NewExpandableDocumentCommand\UseExamTemplate{mm}{
  \UseName{l@rdxm@template@#1@#2@tl}
}

%% ---------------------------------------------------------------------------
%% Translation commands for exam keywords
%% ---------------------------------------------------------------------------

\DeclareUnknownKeyHandler[randexam/translation]{
  \tlSet{\expName{l@rdxm@translate@\l@rdxm@declare@language@tl @#1@tl}}{#2}
}

%% #1: language name; #2: a keyval list with keyword = transaltion format
\NewDocumentCommand\DeclareExamTranslation{mm}{
  \tlIfEqTF{#1}{current}{
    \tlSetEq\l@rdxm@declare@language@tl\l@rdxm@current@language@tl
  }{
    \tlSet\l@rdxm@declare@language@tl{#1}
  }
  \SetKeys[randexam/translation]{#2}
}

%% #1: a keyval list with keyword = transaltion format
\NewDocumentCommand\SetExamTranslation{m}{
  \tlSetEq\l@rdxm@declare@language@tl\l@rdxm@current@language@tl
  \SetKeys[randexam/translation]{#1}
}

%% #1: language name
\NewDocumentCommand\SelectExamTranslation{m}{
  \tlSet\l@rdxm@current@language@tl{#1}
}

%% #1: keyword name.
%% In an expandable command, we should use \UseName but not \expName.
\NewExpandableDocumentCommand\UseExamTranslation{m}{
  \UseName{l@rdxm@translate@\l@rdxm@current@language@tl @#1@tl}
}

%% #1: keyword translation; #2: keyword number.
%% The \relax prevents functional package from treating the result as a function
\NewDocumentCommand\MakeExamNameNumber{mm}{
  \clistSet\lTmpaClist{\expWhole{#1}}
  \intCompareTF{\clistVarCount\lTmpaClist}>{1}{
    \prgReturn{\relax\clistVarItem\lTmpaClist{1}#2\clistVarItem\lTmpaClist{2}}
  }{
    \prgReturn{#1~#2}
  }
}

\DeclareExamTranslation{english}{
   answertable-Answer   = Answer
  ,answertable-Number   = Number
  ,examdata-Appendix    = Appendix
  ,exampart-Part        = Part
  ,examtitle-Name       = Name
  ,examtitle-Solutions  = Solutions
  ,gradetable-Evaluator = Evaluator
  ,gradetable-Part      = Part
  ,gradetable-Score     = Score
  ,gradetable-Total     = Total
  ,headfoot-Name        = Name
  ,headfoot-of          = of
  ,headfoot-Page        = Page
  ,headfoot-Solutions   = Solutions
  ,headfoot-Version     = Version
  ,points-point         = point
  ,points-points        = points
  ,question-Question    = Question
  ,solution-Solution    = Solution
}

\ExpandArgs{V}\SelectExamTranslation\l@rdxm@current@language@tl

%% ---------------------------------------------------------------------------
%% Keyvalue commands for exam elements
%% ---------------------------------------------------------------------------

%% #1 element name; #2: key definitions
\NewDocumentCommand\DeclareExamValue{m+m}{
  \DeclareKeys[randexam/#1]{#2}
}

%% #1 element name; #2: key name; #3: its value
\NewDocumentCommand\rdxm@set@one@value{mm+m}{
  \tlSet{\expName{l@rdxm@value@#1@#2@tl}}{#3}
}

\newrobustcmd\rdxm@declare@key@handler[1]{
  \DeclareUnknownKeyHandler[randexam/#1]{\rdxm@set@one@value{#1}{##1}{##2}}
}

%% #1 element name; #2: key-value list
\NewDocumentCommand\SetExamValue{m+m}{
  \rdxm@declare@key@handler{#1}
  \SetKeys[randexam/#1]{#2}
}

%% #1: element name; #2: key name.
%% In an expandable command, we should use \UseName but not \expName.
%% When the key is undefined, the expanded result of \UseName is \relax,
%% and we could test this case with \tlIfExist function.
\NewExpandableDocumentCommand\UseExamValue{mm}{
  \UseName{l@rdxm@value@#1@#2@tl}
}

\NewExpandableDocumentCommand\IfExamValueEmptyT{mm+m}{
  \ifcsempty{l@rdxm@value@#1@#2@tl}{#3}{}
}
\NewExpandableDocumentCommand\IfExamValueEmptyF{mm+m}{
  \ifcsempty{l@rdxm@value@#1@#2@tl}{}{#3}
}
\NewExpandableDocumentCommand\IfExamValueEmptyTF{mm+m+m}{
  \ifcsempty{l@rdxm@value@#1@#2@tl}{#3}{#4}
}

%% In fact, \ifdef/ifcsname is a wrapper for \ifdefined/\ifcsname in eTeX;
%% they will not turn an undefined macro into \relax
\NewExpandableDocumentCommand\IfExamValueExistT{mm+m}{
  \ifcsdef{l@rdxm@value@#1@#2@tl}{#3}{}
}
\NewExpandableDocumentCommand\IfExamValueExistF{mm+m}{
  \ifcsdef{l@rdxm@value@#1@#2@tl}{}{#3}
}
\NewExpandableDocumentCommand\IfExamValueExistTF{mm+m+m}{
  \ifcsdef{l@rdxm@value@#1@#2@tl}{#3}{#4}
}

%% #1 element name
\NewDocumentCommand\TheExamCounter{m}{
  \UseExamValue{#1}{number}{#1}
}

%% ---------------------------------------------------------------------------
%% Theme commands for exam papers
%% ---------------------------------------------------------------------------

%% #1: theme name; #2: theme code
\NewDocumentCommand\DeclareExamTheme{m+m}{
  \tlSet{\expName{l@rdxm@theme@#1@tl}}{#2}
}

%% #1: theme name
\NewDocumentCommand\SelectExamTheme{m}{
  \UseName{l@rdxm@theme@#1@tl}
}

\DeclareKeys[randexam]{
  theme .code = \SelectExamTheme{#1}
}

%% ---------------------------------------------------------------------------
%% Fill commands for exam papers
%% ---------------------------------------------------------------------------

\NewDocumentCommand\ExamFillCdot{}{
  \leavevmode\xleaders\hbox to 0.5em{\hss$\cdot$\hss}\hfill\kern0pt\relax
}

\NewDocumentCommand\ExamFillUline{}{
  \xleaders\hbox{\underline{\kern1pt}}\hfill\kern0pt
}

\NewDocumentCommand\ExamFillUlinePhantom{m}{
  \xleaders\hbox{\underline{\vphantom{#1}\kern1pt}}\hfill\kern0pt
}

\NewDocumentCommand\ExamFillUlineText{m}{
  \ExamFillUlinePhantom{#1}\underline{#1}\ExamFillUlinePhantom{#1}
}

%% ---------------------------------------------------------------------------
%% Command for exam title: \examtitle
%% ---------------------------------------------------------------------------

\newcommand{\underspace}[1]{\kern0pt\underline{\hspace{#1}}\kern0pt\relax}
\newcommand{\underbox}[2]{\kern0pt\underline{\makebox[#1]{#2}}\kern0pt\relax}
\newcommand{\underparbox}[2]{\kern0pt\underline{\parbox[b]{#1}{#2}}\kern0pt\relax}

\rdxm@declare@key@handler{examtitle}

\SetExamValue{examtitle}{name=Math~1906,date=\today,version=A}

\DeclareExamTemplate{examtitle}{normal}{
  \begingroup
  \Large\noindent
  \IfExamBoolTF{answer}{
    \textcolor{red!80!black}{
      \UseExamValue{examtitle}{name}\hfill\UseExamTranslation{examtitle-Solutions}
    }
  }{
    \UseExamValue{examtitle}{name}\hfill\UseExamTranslation{examtitle-Name}:\underspace{6em}
  }\par
  \endgroup
}
\SelectExamTemplate{examtitle}{normal}

\NewDocumentCommand\examtitle{+m}{
  \SetExamValue{examtitle}{#1}
  \IfExamBoolF{plain}{\thispagestyle{fancyfirst}}
  \IfExamBoolT{random}{
    \tlIfEqT{\expWhole{\UseExamValue{examtitle}{version}}}{A}{
      \SetExamValue{examtitle}{version=B}
    }
    \tlIfEqT{\expWhole{\UseExamValue{examtitle}{version}}}{C}{
      \SetExamValue{examtitle}{version=D}
    }
  }
  \UseExamTemplate{examtitle}{default}
}

%% ---------------------------------------------------------------------------
%% Command for grade table: \gradetable
%% ---------------------------------------------------------------------------

%% total: total number of parts in current exam;
%% strut: strut height in the score row.
\rdxm@declare@key@handler{gradetable}
\SetKeys[randexam/gradetable]{total=6,strut=2.5em}

\newcounter{@exam@grade@cnt}
\newrobustcmd\rdxm@part@number[1]{
  \setcounter{@exam@grade@cnt}{#1}
  \UseExamValue{exampart}{number}{@exam@grade@cnt}
}

%% #1: the tl variable; #2: the first cell; #3: the last cell
%% #4: the number of middle cells; #5: the map command for middle cells.
\newrobustcmd\rdxm@table@make@row[5]{
  \tlSet#1{#2 & }
  \intStepOneInline{1}{#4}{
    \tlPutRight#1{#5{##1} &}
  }
  \tlPutRight#1{ #3}
}

\newrobustcmd\rdxm@gobble@one[1]{}

%% \dimeval or \dimexpr doesn't accept decimal numbers such as 0.3
\NewDocumentCommand\MakeExamStruct{m}{
  \rule[-\dimeval{(#1)*3/10}]{0pt}{#1}
}

\DeclareExamTemplate{gradetable}{normal}{
  \rdxm@table@make@row
    \l@rdxm@gradetable@part@tl
    {\textbf{\UseExamTranslation{gradetable-Part}}}
    {\UseExamTranslation{gradetable-Total}}
    {\UseExamValue{gradetable}{total}}
    \rdxm@part@number
  \rdxm@table@make@row
    \l@rdxm@gradetable@score@tl
    {\textbf{\UseExamTranslation{gradetable-Score}}
         \MakeExamStruct{\UseExamValue{gradetable}{strut}}}
    {}
    {\UseExamValue{gradetable}{total}}
    \rdxm@gobble@one
  \IfExamBoolT{evaluator}{
    \rdxm@table@make@row
      \l@rdxm@gradetable@evaluator@tl
      {\textbf{\UseExamTranslation{gradetable-Evaluator}}
           \MakeExamStruct{\UseExamValue{gradetable}{strut}}}
      {}
      {\UseExamValue{gradetable}{total}}
      \rdxm@gobble@one
  }
  \noindent
  \begin{tabularx}{\linewidth}{|c|*{\UseExamValue{gradetable}{total}}{Y|}Y|}
    \hline
    \l@rdxm@gradetable@part@tl \\ \hline
    \l@rdxm@gradetable@score@tl \\ \hline
    \IfExamBoolT{evaluator}{\l@rdxm@gradetable@evaluator@tl \\ \hline}
  \end{tabularx}
}
\SelectExamTemplate{gradetable}{normal}

\NewDocumentCommand\gradetable{O{}}{
  \par\vspace{1em}
  \begingroup
  \SetKeys[randexam/gradetable]{#1}
  \UseExamTemplate{gradetable}{default}
  \endgroup
}

%% ---------------------------------------------------------------------------
%% Setting header and footer
%% ---------------------------------------------------------------------------

\DeclareExamTemplate{headleft}{empty}{}
\DeclareExamTemplate{headcenter}{empty}{}
\DeclareExamTemplate{headright}{empty}{}
\DeclareExamTemplate{footleft}{empty}{}
\DeclareExamTemplate{footcenter}{empty}{}
\DeclareExamTemplate{footright}{empty}{}

\DeclareExamTemplate{headleft}{plain}{}
\DeclareExamTemplate{headcenter}{plain}{}
\DeclareExamTemplate{headright}{plain}{}
\DeclareExamTemplate{footleft}{plain}{}
\DeclareExamTemplate{footcenter}{plain}{\thepage}
\DeclareExamTemplate{footright}{plain}{}

\DeclareExamTemplate{headleft}{fancy}{
  \UseExamValue{examtitle}{name}
}
\DeclareExamTemplate{headcenter}{fancy}{}
\DeclareExamTemplate{headright}{fancy}{
  \IfExamBoolTF{answer}{
    \UseExamTranslation{headfoot-Solutions}
  }{
    \UseExamTranslation{headfoot-Name}:\hspace{12em}
  }
}
\DeclareExamTemplate{footleft}{fancy}{
  \UseExamValue{examtitle}{date}
}
\DeclareExamTemplate{footcenter}{fancy}{
  \MakeExamNameNumber{\UseExamTranslation{headfoot-Page}}{\thepage}
  \space
  \MakeExamNameNumber{\UseExamTranslation{headfoot-of}}{\zpageref{LastPage}}
}
\DeclareExamTemplate{footright}{fancy}{
  \MakeExamNameNumber{\UseExamTranslation{headfoot-Version}}
      {\UseExamValue{examtitle}{version}}
}

\tlSet\l@rdxm@headtext@tl{
  \UseExamTemplate{headleft}{default}
  \hfill
  \UseExamTemplate{headcenter}{default}
  \hfill
  \UseExamTemplate{headright}{default}
}

\tlSet\l@rdxm@foottext@tl{
  \UseExamTemplate{footleft}{default}
  \hfill
  \UseExamTemplate{footcenter}{default}
  \hfill
  \UseExamTemplate{footright}{default}
}

\newrobustcmd\rdxm@columnbox[1]{\makebox[\columnwidth]{#1}}

\newrobustcmd\rdxm@other@pages@only[1]{\ifnumgreater{\value{page}}{1}{#1}{}}
\newrobustcmd\rdxm@fancyhead[2][]{\fancyhead[#1]{\rdxm@other@pages@only{#2}}}
\newrobustcmd\rdxm@fancyfoot[2][]{\fancyfoot[#1]{\rdxm@other@pages@only{#2}}}

\IfExamBoolTF{twoinone}{
  \rdxm@fancyhead[L]{\small\underline{\rdxm@columnbox{\l@rdxm@headtext@tl}\strut}}
  \fancyhead[C]{}
  \fancyhead[R]{\small\underline{\rdxm@columnbox{\l@rdxm@headtext@tl}\strut}}
  \fancyfoot[L]{\small\rdxm@columnbox{\l@rdxm@foottext@tl}}
  \fancyfoot[C]{}
  \fancyfoot[R]{\small\rdxm@columnbox{\stepcounter{page}\l@rdxm@foottext@tl}}
}{
  \rdxm@fancyhead[L]{\small\UseExamTemplate{headleft}{default}}
  \rdxm@fancyhead[C]{\small\UseExamTemplate{headcenter}{default}}
  \rdxm@fancyhead[R]{\small\UseExamTemplate{headright}{default}}
  \fancyfoot[L]{\small\UseExamTemplate{footleft}{default}}
  \fancyfoot[C]{\small\UseExamTemplate{footcenter}{default}}
  \fancyfoot[R]{\small\UseExamTemplate{footright}{default}}
}

%% plain page style
\fancypagestyle{plain}{
  \renewcommand\headrulewidth{0pt}
  \fancyhead{}
  \SelectExamTemplate{footleft}{plain}
  \SelectExamTemplate{footcenter}{plain}
  \SelectExamTemplate{footright}{plain}
}

%% fancy page style
\tlSet\l@rdxm@fancy@page@code@tl{
  \SelectExamTemplate{headleft}{fancy}
  \SelectExamTemplate{headcenter}{fancy}
  \SelectExamTemplate{headright}{fancy}
  \SelectExamTemplate{footleft}{fancy}
  \SelectExamTemplate{footcenter}{fancy}
  \SelectExamTemplate{footright}{fancy}
}
\fancypagestyle{fancy}{
  \IfExamBoolTF{twoinone}{
    \renewcommand\headrulewidth{0pt}
  }{
    \renewcommand\headrulewidth{0.4pt}
  }
  \l@rdxm@fancy@page@code@tl
}
\fancypagestyle{fancyfirst}{
  \renewcommand\headrulewidth{0pt}
  \l@rdxm@fancy@page@code@tl
}

%% set page style at this time since users may change header/footer templates
\AtBeginDocument{\IfExamBoolTF{plain}{\pagestyle{plain}}{\pagestyle{fancy}}}

%% ---------------------------------------------------------------------------
%% Class option for shuffling questions: random
%% Class option for random seed: seed
%% ---------------------------------------------------------------------------

%% The random seed could not exceed 2147483647 = "7FFFFFFF
%% You need to put .store before .initial:n
\DeclareKeys[randexam]{
  seed .store     = \rdxm@random@seed,
  seed .initial:n = 19061116
}

\IfExamBoolT{random}{
  \RequirePackage{pgf}
  \RequirePackage{pgffor}
  \newcommand*\exam@set@seed{
    %% When the argument of \pgfmathrandom is a multiple of three,
    %% the random numbers generated by nearby seeds are not uniformly distributed
    %\pgfmathsetseed{\numexpr\rdxm@random@seed+\value{exampart}-1\relax}
    %% Therefore we take this approach: generating next random seed with current seed
    \pgfmathsetseed{\rdxm@random@seed}
    \pgfmathrandominteger\rdxm@random@seed{1}{2147483647}
  }
}

%% ---------------------------------------------------------------------------
%% Command for exam groups: \exampart
%% Command for appendix data: \examdata
%% Environment for questions: question
%% Environment for solutions: solution
%% ---------------------------------------------------------------------------

\newcounter{exampart}
\renewcommand\theexampart{\Roman{exampart}}

\rdxm@declare@key@handler{exampart}
\SetExamValue{exampart}{number=\Roman}

%% No displaying question number when there is only one question in the part
\NewExamBool{onlyonequestion}\SetExamBoolFalse{onlyonequestion}

\xdef\allquestions{}
\xdef\lastquestion{}

%% question: problem number within current part
%% questionreal: problem number for display, used when exam@resetnumber=false
%% totalquestions: total number of problems in previous parts, used when exam@resetnumber=false
\newcounter{question}
\newcounter{questionreal}
\newcounter{totalquestions}

\newcounter{choice} % used in abcd environment
\newcommand{\hangtext}{}
\newlength{\hanglength}
\colorlet{part~number}{black}
\colorlet{question~number}{blue!80!black}
\colorlet{solution~name}{blue!80!black}

\newcounter{rdxm@shuffle@temp@cnt}
\newcounter{rdxm@list@temp@cnt}

\newcommand\rdxm@list@print[1]{
  \par\renewcommand*{\do}[1]{(##1)}
  \dolistloop#1%
}

\newcommand\rdxm@list@remove[2]{
  %\rdxm@list@print\rdxm@shuffle@list
  \setcounter{rdxm@list@temp@cnt}{0}
  \global\let\rdxm@tmpa@list=#1
  \gdef#1{}%
  \par\renewcommand*{\do}[1]{
    \stepcounter{rdxm@list@temp@cnt}
    \ifnumequal{\value{rdxm@list@temp@cnt}}{#2}{
      \def\rdxm@list@item{##1}
      %[##1]
    }{
      \listxadd#1{##1}
    }%
  }%
  \dolistloop\rdxm@tmpa@list
}

\newcommand\rdxm@shuffle@questions{
  \exam@set@seed
  \ifnumgreater{\value{question}}{2}{
    \gdef\rdxm@shuffle@list{}
    \foreach \i in {1,...,\value{question}} {\listxadd\rdxm@shuffle@list{\i}}
    %% always change the postions of the first and the last questions
    \pgfmathrandom{2,\value{question}}
    \rdxm@list@remove\rdxm@shuffle@list{\pgfmathresult}
    \global\csletcs{rdxm@question@b@1}{rdxm@question@a@\rdxm@list@item}
    \ifnumequal{\rdxm@list@item}{\value{question}}{
      \pgfmathrandom{\numexpr\value{question}-1\relax}
      \rdxm@list@remove\rdxm@shuffle@list{\pgfmathresult}
      \global\csletcs{rdxm@question@b@\the\value{question}}{rdxm@question@a@\rdxm@list@item}
    }{
      \pgfmathrandom{\numexpr\value{question}-2\relax}
      \rdxm@list@remove\rdxm@shuffle@list{\pgfmathresult}
      \global\csletcs{rdxm@question@b@\the\value{question}}{rdxm@question@a@\rdxm@list@item}
    }
    %% no restrition for questions in the middle
    \setcounter{rdxm@shuffle@temp@cnt}{1}
    \whileboolexpr{
      test{\ifnumless{\value{rdxm@shuffle@temp@cnt}}{\numexpr\value{question}-1\relax}}
    }{
      \stepcounter{rdxm@shuffle@temp@cnt}
      \pgfmathrandom{\numexpr\value{question}-\value{rdxm@shuffle@temp@cnt}\relax}
      \rdxm@list@remove\rdxm@shuffle@list{\pgfmathresult}
      \global\csletcs{rdxm@question@b@\the\value{rdxm@shuffle@temp@cnt}}{
        rdxm@question@a@\rdxm@list@item
      }
    }
  }{
    \ifnumequal{\value{question}}{2}{
      \global\csletcs{rdxm@question@b@1}{rdxm@question@a@2}
      \global\csletcs{rdxm@question@b@2}{rdxm@question@a@1}
    }{}
  }
}

\newcommand{\printquestions}{
  \IfExamBoolT{random}{
    \rdxm@appto@questions
    \rdxm@shuffle@questions
    \setcounter{question}{0}
    \allquestions
  }
  \xdef\allquestions{}
  \xdef\lastquestion{}
}

\DeclareExamTemplate{exampart}{normal}{
  \noindent
  \textbf{
    \textcolor{part~number}{
      \MakeExamNameNumber{\UseExamTranslation{exampart-Part}}{\TheExamCounter{exampart}}
    }
    :~\UseExamValue{exampart}{type}
  }
  \IfExamValueEmptyF{exampart}{points}{
    \space(\UseExamValue{exampart}{points})
  }
}
\SelectExamTemplate{exampart}{normal}

\NewDocumentCommand\exampart{+m+O{}}{
  \printquestions
  \setcounter{totalquestions}{\value{totalquestions}+\value{question}}
  \setcounter{question}{0}
  \stepcounter{exampart}
  \vspace{1em}
  \begingroup
  \SetExamValue{exampart}{type=#1,points=#2}
  \UseExamTemplate{exampart}{default}
  \endgroup
  \par\nopagebreak
  \if\relax\detokenize{#1}\relax % #1 is empty
    \SetExamBoolTrue{onlyonequestion}
  \else
    \SetExamBoolFalse{onlyonequestion}
    \vspace{1em}
  \fi
  % \@afterheading sets \@nobreaktrue, which will prevent page breaks before lists;
  % see source2e
  \@afterheading
}

\DeclareExamTemplate{examdata}{normal}{
  \centerline{
    \textbf{\UseExamTranslation{examdata-Appendix}}
    \quad\UseExamValue{examdata}{caption}
  }
  \smallskip
}
\SelectExamTemplate{examdata}{normal}

\NewDocumentCommand\examdata{+m}{
  \printquestions\rdxm@stop@random
  \SetExamValue{examdata}{caption=#1}
  \UseExamTemplate{examdata}{default}
}

%% this equals to \AddToHook{enddocument}[randexam]{...}
\AtEndDocument{\printquestions\rdxm@stop@random}

\newcommand\ignorepars{\@ifnextchar\par{\expandafter\ignorepars\@gobble}{}}

\rdxm@declare@key@handler{question}

\newcommand\pointorpoints[1]{
  \ifnumgreater{#1}{1}{
    \UseExamTranslation{points-points}
  }{
    \UseExamTranslation{points-point}
  }
}

\newcommand{\questionpointstext}[1]{ (#1~\pointorpoints{#1}) }

\newcommand\rdxm@hook@exec@other@keys{}

\newrobustcmd\execute@question@keys{
  \rdxm@hook@exec@other@keys
  \IfExamValueExistT{question}{points}{
    \questionpointstext{\UseExamValue{question}{points}}
  }
}

\DeclareExamTemplate{questionbegin}{normal}{
  \IfExamBoolTF{resetnumber}{
    \IfExamBoolTF{onlyonequestion}{
      \renewcommand{\hangtext}{\qquad}
    }{
      \renewcommand{\hangtext}{\textbf{\textsf{\textcolor{question~number}{\arabic{question}}.}}\;\,}
    }
  }{
    \setcounter{questionreal}{\value{totalquestions}+\value{question}}
    \renewcommand{\hangtext}{\textbf{\textsf{\textcolor{question~number}{\arabic{questionreal}}.}}\;\,}
  }
  \settowidth{\hanglength}{\hangtext}
  \description[leftmargin=\hanglength,labelwidth=0pt,labelsep=0pt,topsep=0pt,parsep=0pt]
  \item[\hangtext]\execute@question@keys
}
\SelectExamTemplate{questionbegin}{normal}

\DeclareExamTemplate{questionend}{normal}{\enddescription}
\SelectExamTemplate{questionend}{normal}

\NewDocumentEnvironment{questionreal}{O{}}{
  \stepcounter{question}
  \setcounter{choice}{0}
  \SetKeys[randexam/question]{#1}
  \UseExamTemplate{questionbegin}{default}
}{
  \UseExamTemplate{questionend}{default}
}

\DeclareExamTemplate{solutionbegin}{normal}{
  \renewcommand{\hangtext}{
    \textbf{\textsf{\textcolor{solution~name}{\UseExamTranslation{solution-Solution}}.}}\;\,
  }
  \settowidth{\hanglength}{\hangtext}
  \description[leftmargin=\hanglength,labelwidth=0pt,labelsep=0pt,topsep=0pt,parsep=0pt]
  \item[\hangtext]
}
\SelectExamTemplate{solutionbegin}{normal}

\DeclareExamTemplate{solutionend}{normal}{\enddescription}
\SelectExamTemplate{solutionend}{normal}

\NewDocumentEnvironment{solutionreal}{}{
  \UseExamTemplate{solutionbegin}{default}
}{
  \UseExamTemplate{solutionend}{default}
}

\let \oldnewpage   = \newpage
\let \oldvfill     = \vfill
\let \oldsmallskip = \smallskip
\let \oldmedskip   = \medskip
\let \oldbigskip   = \bigskip

\IfExamBoolTF{random}{
  \newcommand\rdxm@appto@questions{
    \xappto\allquestions{\expandonce\lastquestion}
  }
  \NewEnviron{question}{
    \stepcounter{question}
    \rdxm@appto@questions
    \csxdef{rdxm@question@a@\the\value{question}}{
      \unexpanded{\begin{questionreal}}
      \unexpanded\expandafter{\BODY}
      \unexpanded{\end{questionreal}}
    }
    \csxdef{rdxm@question@b@\the\value{question}}{
      \expandonce{\csname rdxm@question@a@\the\value{question}\endcsname}
    }
    \xdef\lastquestion{
      \expandonce{\csname rdxm@question@b@\the\value{question}\endcsname}
    }
  }
  \NewEnviron{solution}{
    \csxappto{rdxm@question@a@\the\value{question}}{
      \unexpanded{\begin{solutionreal}}
      \expandonce{\BODY}
      \unexpanded{\end{solutionreal}}
    }%
  }
  \renewcommand{\newpage}{\gappto\lastquestion{\oldnewpage}}
  \renewcommand{\vfill}{\csgappto{rdxm@question@a@\the\value{question}}{\oldvfill}}
  \renewcommand{\smallskip}{\csgappto{rdxm@question@a@\the\value{question}}{\oldsmallskip}}
  \renewcommand{\medskip}{\csgappto{rdxm@question@a@\the\value{question}}{\oldmedskip}}
  \renewcommand{\bigskip}{\csgappto{rdxm@question@a@\the\value{question}}{\oldbigskip}}
}{
  \newenvironment{question}[1][]{\questionreal[#1]}{\endquestionreal}
  %\newenvironment{solution}{\solutionreal}{\endsolutionreal}
  \NewEnviron{solution}{\begin{solutionreal}\BODY\end{solutionreal}}
}

\newcommand{\rdxm@stop@random}{
  \IfExamBoolT{random}{
    \renewenvironment{question}{\questionreal}{\endquestionreal}
    \renewenvironment{solution}{\solutionreal}{\endsolutionreal}
    \let \newpage   = \oldnewpage
    \let \vfill     = \oldvfill
    \let \smallskip = \oldsmallskip
    \let \medskip   = \oldmedskip
    \let \bigskip   = \oldbigskip
  }
}

\def\CommentCutFile{\jobname.cut}

\AtBeginDocument{
  \IfExamBoolF{answer}{\excludecomment{solution}}
}

%% ---------------------------------------------------------------------------
%% Command for answer tables: \answertable
%% ---------------------------------------------------------------------------

%% total: total number of questions in current exam part;
%% column: number of questions in each answer row;
%% strut: strut height in each answer rows;
%% notice: notice text before the answer table.
\rdxm@declare@key@handler{answertable}
\SetKeys[randexam/answertable]{
   strut  = 1em
  ,notice = {Notice:~you~MUST~write~the~answers~in~the~following~tables.}
}

\gdef\answer@lines@temp{}
\newcommand{\answer@lines@add}[1]{
  \xdef\answer@lines@temp{\answer@lines@temp#1}
}

\newrobustcmd\answer@number@hided[1]{\UseExamTranslation{answertable-Number}}
\newrobustcmd\answer@cell@strut[1]{
  \parbox[c][#1][c]{2em}{\hbox{\UseExamTranslation{answertable-Answer}}}
}

\newcounter{answer@col}
\newcounter{answer@row}
\newcounter{answer@total}

%% #1: strut; #2: total; #3: column.
\newcommand{\answer@lines}[3]{
  % change rounding down to rounding up in the division
  \setcounter{answer@row}{(#2-1)/#3+1}
  \begingroup
  \let\hline=\relax  \let\\=\relax % forbid expansions
  \gdef\answer@lines@temp{}
  \setcounter{answer@total}{1}
  \whileboolexpr{
      test{\ifnumgreater{\value{answer@row}}{0}}
  }{
      \addtocounter{answer@row}{-1}
      \answer@lines@add{\answer@number@hided}
      \setcounter{answer@col}{1}
      \unlessboolexpr{
          test{\ifnumgreater{\value{answer@col}}{#3}}
      }{
          \answer@lines@add{&}
          \ifnumgreater{\value{answer@total}}{#2}{}{
            \answer@lines@add{\arabic{answer@total}}
          }
          \stepcounter{answer@col}
          \stepcounter{answer@total}
      }
      \answer@lines@add{\\ \hline \answer@cell@strut{#1}}
      \setcounter{answer@col}{1}
      \unlessboolexpr{
          test{\ifnumgreater{\value{answer@col}}{#3}}
      }{
          \answer@lines@add{&}
          \stepcounter{answer@col}
      }
      \answer@lines@add{\\ \hline}
  }
  \endgroup
  \answer@lines@temp
}

\DeclareExamTemplate{answertable}{normal}{
  \UseExamValue{answertable}{notice}\par
  \begin{tabularx}{\linewidth}{|c|*{\UseExamValue{answertable}{column}}{Y|}}
    \hline
    \answer@lines{\UseExamValue{answertable}{strut}}
      {\UseExamValue{answertable}{total}}{\UseExamValue{answertable}{column}}
  \end{tabularx}
}
\SelectExamTemplate{answertable}{normal}

\NewDocumentCommand\answertable{O{}}{
  \begingroup
  \SetKeys[randexam/answertable]{#1}
  \UseExamTemplate{answertable}{default}
  \endgroup
  \par\vspace{0.8em}
}

%% ---------------------------------------------------------------------------
%% Command for toggling answers: \answer
%% Command for true-or-false questions: \tickin and \tickout
%% Command for fill-in-the-blank questions: \fillin and \fillout
%% Command for multiple-choice questions: \pickin and \pickout
%% ---------------------------------------------------------------------------

\newcommand{\answer}[1]{\IfExamBoolTF{answer}{#1}{\phantom{#1}}}

\newcommand*{\tick@box}[1]{[\makebox[1.5em]{\color{blue}\answer{#1}}]}
\newcommand*{\tick@text@t}{$\checkmark$}
\newcommand*{\tick@text@f}{{\large$\times$}}
\newcommand*{\tick@text@T}{\sffamily T}
\newcommand*{\tick@text@F}{\sffamily F}

\NewDocumentCommand\tickin{m}{
  \tick@box{\csname tick@text@#1\endcsname}
}
\NewDocumentCommand\tickout{m}{
  \unskip\nobreak\ExamFillCdot\tick@box{\csname tick@text@#1\endcsname}
}

\newcommand*{\minwidthbox}[2]{\makebox[{\ifdim#1<\width\width\else#1\fi}]{#2}}

\NewDocumentCommand\fillout{m}{
  \allowbreak\hbox{}\nobreak\ExamFillUlineText{\color{blue}\answer{#1}}
}
\NewDocumentCommand\fillin{m}{
  \underline{\hspace{1em}\color{blue}\minwidthbox{2em}{\answer{#1}}\hspace{1em}}
}

\newcommand*\pickoutreal[1]{
  \unskip\nobreak\ExamFillCdot(\makebox[1.5em]{\color{blue}\answer{#1}})
}
\newcommand*\pickinreal[1]{
  \unskip\nobreak
  \hspace{0.3em}(\makebox[1.5em]{\color{blue}\answer{#1}})\hspace{0.3em}
  \ignorespaces
}

%% We choose three ways for shuffling four choices in a multiple-choice question
%% 1：ABCD -> CDAB； 2：ABCD -> BADC; 3: ABCD -> DCBA
%% In other word, we only exchange choices in the same row or column,
%% so as to make the lengths of choice lines unchanged

\csdef{rdxm@shuffle@1@A}{C} \csdef{rdxm@shuffle@2@A}{B} \csdef{rdxm@shuffle@3@A}{D}
\csdef{rdxm@shuffle@1@B}{D} \csdef{rdxm@shuffle@2@B}{A} \csdef{rdxm@shuffle@3@B}{C}
\csdef{rdxm@shuffle@1@C}{A} \csdef{rdxm@shuffle@2@C}{D} \csdef{rdxm@shuffle@3@C}{B}
\csdef{rdxm@shuffle@1@D}{B} \csdef{rdxm@shuffle@2@D}{C} \csdef{rdxm@shuffle@3@D}{A}

\def\@rdxm@choice@random{0}
\newcommand\rdxm@shuffle@abcd[1]{\csuse{rdxm@shuffle@\@rdxm@choice@random @#1}}

\newcommand*\pickout[1]{
  \IfExamBoolTF{random}{
    \exam@set@seed
    \pgfmathrandominteger\@rdxm@choice@random{1}{3}
    %\@rdxm@choice@random
    \pickoutreal{\rdxm@shuffle@abcd{#1}}
  }{
    \pickoutreal{#1}
  }
}
\newcommand*\pickoutfixed[1]{
  \pickoutreal{#1}
  \SetExamBoolFalse{random}
}
\newcommand*\pickin[1]{
  \IfExamBoolTF{random}{
    \exam@set@seed
    \pgfmathrandominteger\@rdxm@choice@random{1}{3}
    %\@rdxm@choice@random
    \pickinreal{\rdxm@shuffle@abcd{#1}}
  }{
    \pickinreal{#1}
  }
}
\newcommand*\pickinfixed[1]{
  \pickinreal{#1}
  \SetExamBoolFalse{random}
}

%% ---------------------------------------------------------------------------
%% Environment abcd for typesetting options of multiple-choice questions
%% Put them in one, two, or four rows according to the lengths of the choices
%% ---------------------------------------------------------------------------

\newlength{\rdxm@item@len}
\newlength{\rdxm@label@len}

\newcommand\rdxm@item@temp{
  \unskip\cr\stepcounter{choice}(\Alph{choice})\ 
}
\newcommand\rdxm@item@box{
  \hfill\egroup\hfill\hbox to \rdxm@item@len\bgroup
  \stepcounter{choice}(\Alph{choice})\ \ignorespaces
}
\newcommand\rdxm@item@par{
  \stepcounter{choice}
  \def\rdxm@label@text{(\Alph{choice})\ }
  \settowidth{\rdxm@label@len}{\rdxm@label@text}
  \par \parshape 2 \hanglength \linewidth
  \dimexpr\hanglength + \rdxm@label@len\relax
  \dimexpr\linewidth - \rdxm@label@len\relax
  \rdxm@label@text\ignorespaces
}

\NewEnviron{abcdreal}{
  \unskip
  \setlength{\parindent}{0pt}
  \setlength{\parskip}{0pt}
  \setcounter{choice}{0}
  \let\item=\rdxm@item@temp
  \settowidth{\rdxm@item@len}{\vbox{\halign{##\hfil\cr\BODY\crcr}}}
  \setcounter{choice}{0}
  \ifdim\rdxm@item@len>0.486\linewidth
    \setlength{\rdxm@item@len}{\linewidth}
    \let\item=\rdxm@item@par
    \BODY\par
  \else
    \ifdim\rdxm@item@len>.243\linewidth
      \setlength{\rdxm@item@len}{0.5\linewidth}
    \else
      \setlength{\rdxm@item@len}{0.25\linewidth}
    \fi
    \let\item=\rdxm@item@box
    \par\bgroup\BODY\hfill\egroup\par
  \fi
}

\newcommand\rdxm@item@one@line{
  \unskip
  \ifnumequal{\value{choice}}{0}{}{\hfill}
  \stepcounter{choice}(\Alph{choice})\ 
}
\newcommand\rdxm@item@two@line{
  \unskip
  \ifnumodd{\value{choice}}{&}{\unskip\cr}
  \stepcounter{choice}(\Alph{choice})\ 
}

\NewEnviron{abcd*real}{
  \unskip
  \setlength{\parindent}{0pt}
  \setlength{\parskip}{0pt}
  \setcounter{choice}{0}
  \let\item=\rdxm@item@one@line
  \settowidth{\rdxm@item@len}{\BODY}
  \ifdim\rdxm@item@len<0.95\linewidth
    \setcounter{choice}{0}
    \par\bgroup\BODY\hfill\hfill\par\egroup\par
  \else
    \setcounter{choice}{0}
    \let\item=\rdxm@item@two@line
    \settowidth{\rdxm@item@len}{\vbox{\halign{##&##\hfil\cr\BODY\crcr}}}
    \ifdim\rdxm@item@len<0.975\linewidth
      \setcounter{choice}{0}
      \par\bgroup\nointerlineskip
      \vbox{\halign to\linewidth{##\hfil\tabskip=0pt plus 1fil&##\hfil\cr\BODY\crcr}}
      \egroup\par
    \else
      \setcounter{choice}{0}
      \let\item=\rdxm@item@par
      \par\bgroup\BODY\hfill\egroup\par
    \fi
  \fi
}

\IfExamBoolT{random}{
  \csdef{rdxm@swap@items@1}#1#2#3#4{\item#3\item#4\item#1\item#2}
  \csdef{rdxm@swap@items@2}#1#2#3#4{\item#2\item#1\item#4\item#3}
  \csdef{rdxm@swap@items@3}#1#2#3#4{\item#4\item#3\item#2\item#1}
  \long\def\rdxm@swap@items#1\item#2\item#3\item#4\item#5\@rdxm@stop@mark{
    #1\csuse{rdxm@swap@items@\@rdxm@choice@random}{#2}{#3}{#4}{#5}
  }
}

\NewDocumentEnvironment{abcd}{+b}{
  \IfExamBoolTF{random}{
    \begin{abcdreal}\rdxm@swap@items#1\@rdxm@stop@mark\end{abcdreal}
  }{
    \begin{abcdreal}#1\end{abcdreal}
  }
}{}
\NewDocumentEnvironment{abcd*}{+b}{
  \IfExamBoolTF{random}{
    \begin{abcd*real}\rdxm@swap@items#1\@rdxm@stop@mark\end{abcd*real}
  }{
    \begin{abcd*real}#1\end{abcd*real}
  }
}{}

%% ---------------------------------------------------------------------------
%% Use hangindent in enumerate lists, and remove extra vertical space
%% The itemjoin set space between items in inline enumerate* environment
%% ---------------------------------------------------------------------------

\setlist[enumerate]{labelindent=0pt,labelsep=0.2em,itemindent=0pt,leftmargin=*,nosep,itemjoin=\quad}
\setlist[enumerate,1]{label=(\arabic*)}
\setlist[enumerate,2]{label=(\alph*),widest*=1}

%% ---------------------------------------------------------------------------
%% Use freealign package to align math formulas in different lines
%% ---------------------------------------------------------------------------

\AtBeginDocument{
  \IfExamBoolT{freealign}{\RequirePackage{freealign}}
}

%% ---------------------------------------------------------------------------
%% Command for giving points in solutions: \points
%% ---------------------------------------------------------------------------

\PassOptionsToPackage{tbtags}{amsmath}
\RequirePackage{amsmath}

\newcommand{\solutionpointstext}[1]{
  \textcolor{red}{#1\kern0.15em\pointorpoints{#1}}
}

\newcommand{\pointstext}[1]{
  \mbox{}\nobreak\hfill$\cdots\cdots$\solutionpointstext{#1}
  \par\noindent\ignorespaces
}

%% \eqno would cause extra space after a $$...$$ equation
%% this bug was fixed in latex release 2023-06-01
%% see https://github.com/latex3/latex2e/issues/1059
%% \tag is used in a \[...\] equation hence no problem with it
\newcommand{\pointseqno}[1]{\eqno{\cdots\cdots\text{\solutionpointstext{#1}}}}
\newcommand{\pointstag}[1]{\tag*{$\cdots\cdots$\solutionpointstext{#1}}}

\newrobustcmd{\points}[1]{
  \ifbool{mmode}{
    \ifdefstrequal{\tag}{\dft@tag}{\pointseqno{#1}}{\pointstag{#1}}
  }{
    \pointstext{#1}
  }
}

%% ---------------------------------------------------------------------------
%% Use medium-size fractions and operators in both inline and displayed formulas
%% ---------------------------------------------------------------------------

\AtBeginDocument{
  \IfExamBoolT{medmath}{\RequirePackage{medmath}}
}

%% ---------------------------------------------------------------------------
%% Load more packages, define more commands
%% ---------------------------------------------------------------------------

\AtBeginDocument{
  \setlength{\abovedisplayskip}{4pt minus 2pt}
  \setlength{\belowdisplayskip}{4pt minus 2pt}
  \setlength{\abovedisplayshortskip}{2pt}
  \setlength{\belowdisplayshortskip}{2pt}
}

\newrobustcmd\rdxm@moremath@limits{
  \AtBeginDocument{
    \let\rdxm@saved@lim=\lim    \def\lim{\rdxm@saved@lim\limits}
    \let\rdxm@saved@sum=\sum    \def\sum{\rdxm@saved@sum\limits}
    \let\rdxm@saved@prod=\prod  \def\prod{\rdxm@saved@prod\limits}
  }
}

\newrobustcmd\rdxm@moremath@differential{
  \newcommand{\diff}{\mathop{}\!\mathrm{d}}
  \newcommand{\dx}{\diff x}
  \newcommand{\dy}{\diff y}
  \def\dz{\diff z} % not sure whether it has been defined
  \newcommand{\du}{\diff u}
  \newcommand{\dv}{\diff v}
  \newcommand{\dr}{\diff r}
  \newcommand{\ds}{\diff s}
  \newcommand{\dt}{\diff t}
  \newcommand{\dS}{\diff S}
  %% Some packages such as hyperref will modify the definition of \d,
  %% so we put the code in \AtBeginDocument.
  %% Also we define \d as a protected command, so as to avoid wrong expansions of
  %% it at the beginning of math arrays such as align from amsmath package.
  \AtBeginDocument{
    \let\oldd=\d
    \renewrobustcmd{\d}{\ifbool{mmode}{\diff}{\oldd}}
  }
  \let\pd=\partial
  \newcommand{\pdf}{\pd f}
  \newcommand{\pdg}{\pd g}
  \newcommand{\pdh}{\pd h}
  \newcommand{\pdl}{\pd l}
  \newcommand{\pdn}{\pd n}
  \newcommand{\pdu}{\pd u}
  \newcommand{\pdv}{\pd v}
  \newcommand{\pdx}{\pd x}
  \newcommand{\pdy}{\pd y}
  \newcommand{\pdz}{\pd z}
  \newcommand{\pdF}{\pd F}
  \newcommand{\pdL}{\pd L}
  \newcommand{\pdP}{\pd P}
  \newcommand{\pdQ}{\pd Q}
  \newcommand{\pdR}{\pd R}
}

\newrobustcmd\rdxm@moremath@widebar{
  %% from mathabx package
  \DeclareFontFamily{U}{mathx}{\hyphenchar\font45}
  \DeclareFontShape{U}{mathx}{m}{n}{<-> mathx10}{}
  \DeclareSymbolFont{mathx}{U}{mathx}{m}{n}
  \DeclareMathAccent{\widebar}{0}{mathx}{"73}
}

\newrobustcmd\rdxm@moremath@vector{
  \newcommand{\va}{\vec{a}}
  \newcommand{\vb}{\vec{b}}
  \newcommand{\vc}{\vec{c}}
  \newcommand{\vd}{\vec{d}}
  \newcommand{\ve}{\vec{e}}
  \newcommand{\vi}{\vec{i}}
  \newcommand{\vj}{\vec{j}}
  \newcommand{\vk}{\vec{k}}
  \newcommand{\vn}{\vec{n}}
  \newcommand{\vs}{\vec{s}}
  \newcommand{\vv}{\vec{v}}
}

\newrobustcmd\rdxm@moremath@widefrac{
  %% Longer fraction rules, \wfrac[2pt]{x}{y} will add 2pt to the left and right
  \AtBeginDocument{
    \newrobustcmd{\wfrac}[3][2pt]{
      \frac{\hspace{##1}##2\hspace{##1}}{\hspace{##1}##3\hspace{##1}}
    }
    \newrobustcmd{\wdfrac}[3][2pt]{
      \dfrac{\hspace{##1}##2\hspace{##1}}{\hspace{##1}##3\hspace{##1}}
    }
    \newrobustcmd{\wtfrac}[3][2pt]{
      \tfrac{\hspace{##1}##2\hspace{##1}}{\hspace{##1}##3\hspace{##1}}
    }
  }
}

\newrobustcmd\rdxm@moremath@whitearrow{
  %% 使用 stix font 中的 white arrows
  \AtBeginDocument{\@ifpackageloaded{fontspec}{
    %\IfFileExists{STIX-Regular.otf}{% 在 TeXLive 中无效
    \IfFileExists{stix.sty}{
      \newfontfamily{\@rdxm@stix}{STIX} % stix v1.1
    }{
      \newfontfamily{\@rdxm@stix}{STIXGeneral} % stix v1.0
    }
    \newrobustcmd\leftwhitearrow{
      \mathrel{\text{\normalfont\@rdxm@stix\symbol{"21E6}}}
    }
    \newrobustcmd\upwhitearrow{
      \mathrel{\text{\normalfont\@rdxm@stix\symbol{"21E7}}}
    }
    \newrobustcmd\rightwhitearrow{
      \mathrel{\text{\normalfont\@rdxm@stix\symbol{"21E8}}}
    }
    \newrobustcmd\downwhitearrow{
      \mathrel{\text{\normalfont\@rdxm@stix\symbol{"21E9}}}
    }
  }{
    \let \leftwhitearrow = \Leftarrow
    \let \rightwhitearrow = \Rightarrow
    \let \upwhitearrow = \Uparrow
    \let \downwhitearrow = \Downarrow
  }}
}

\newrobustcmd\rdxm@moremath@miscellaneous{
  \RequirePackage{mathtools} % for \mathllap command，pmatrix* environment
  \RequirePackage{extarrows}
  \newcommand{\e}{\mathrm{e}}
  \newcommand{\R}{\mathbb{R}}
  \newcommand{\jacobi}[2]{{\left(\frac{##1}{##2}\right)}}
  \newcommand{\ii}{\mathrm{i}}
  \newcommand{\Zi}{\mathbb{Z}[\ii]}
  \DeclareMathOperator{\arccot}{arccot}
  \DeclareMathOperator{\Corr}{\rho}
  \DeclareMathOperator{\Cov}{Cov}
  \DeclareMathOperator{\diag}{diag}
  \DeclareMathOperator{\grad}{grad}
  \DeclareMathOperator{\Prj}{Prj}
  \DeclareMathOperator{\tr}{tr}
  \DeclareMathOperator{\Var}{Var}
  \DeclareMathOperator{\diver}{div}
  \let\division=\div
  \let\div=\diver
  \let\ov=\overrightarrow
  \let\le=\leqslant
  \let\ge=\geqslant
  \let\lb=\{
  \let\rb=\}
  \def\T{\mathrm{T}\kern-.5pt}
}

\IfExamBoolT{moremath}{
  \rdxm@moremath@limits
  \rdxm@moremath@differential
  \rdxm@moremath@widebar
  \rdxm@moremath@vector
  \rdxm@moremath@widefrac
  \rdxm@moremath@whitearrow
  \rdxm@moremath@miscellaneous
}

%% ---------------------------------------------------------------------------
%% Load local user config file
%% ---------------------------------------------------------------------------

\InputIfFileExists{randexam.cfg}{}{}

%% ---------------------------------------------------------------------------
%% Support for Chinese Language
%% ---------------------------------------------------------------------------

\IfExamLanguageEqT{chinese}{\SetExamBoolTrue{ctex}}

\newrobustcmd\rdxm@chinese@ctex{
  %% 四号    小四号    五号      小五号
  %% 14bp    12bp      10.5bp    9bp
  %% 实际上，在旧版本 ctex 中只能用 cs4size 和 c5size 选项
  %% 而新版本 ctex 中，可以利用 zihao 选项指定各种中文字号
  \PassOptionsToPackage{CJKnumber}{xeCJK}
  \RequirePackage[cs4size,UTF8,noindent]{ctex}
  %% 在旧版本 xeCJK 中，必须用 CJKnumber 选项载入 CJKnumb 包，后面才载入会报错
  %% 但在新版本 xeCJK 中 CJKnumber 选项已经被废弃，需要在后面自行载入它
  \RequirePackage{CJKnumb}
  %% 新版本 xeCJK 已经废弃并禁用 CJKfntef，改用 xeCJKfntef 取代，我们需要载入后者
  %% 注意要保证能在较旧的 TeX 系统中编译，我们只能用 \ifXeTeX 而不能用 \ifxetex
  %% 因为旧版本 iftex 宏包只有 \ifXeTeX 命令，而 ifxetex 宏包才有 \ifxetex 命令
  %% 在 2019 年 10 月，LaTeX 开发团队接管了 iftex 宏包，新版本同时提供这两个命令
  \RequirePackage{CJKfntef}
  \RequirePackage{iftex}
  \ifXeTeX\@ifpackagelater{xeCJK}{2020/02/10}{\RequirePackage{xeCJKfntef}}{}\fi
  \ifbool{XeTeX}{
    % https://en.wikipedia.org/wiki/Number_Forms
    % Ⅰ、Ⅱ、Ⅲ、Ⅳ、Ⅴ、Ⅵ、Ⅶ、Ⅷ、Ⅸ、Ⅹ、Ⅺ、Ⅻ
    \xeCJKsetcharclass{"2150}{"218F}{1} % 斜线分数，全角罗马数字等
    % https://en.wikipedia.org/wiki/Enclosed_Alphanumerics
    \xeCJKsetcharclass{"2460}{"24FF}{1} % 带圈数字字母，括号数字字母，带点数字等
  }{}
}
\IfExamBoolT{ctex}{\rdxm@chinese@ctex}

\newrobustcmd\rdxm@chinese@sourcehan{
  \setCJKmainfont[BoldFont=Source~Han~Sans~SC]{Source~Han~Serif~SC}
  \setCJKsansfont{Source~Han~Sans~SC}
  %% 用中文字体名时 LuaTeX 找不到该字体，XeTeX 正常
  %\setCJKmainfont[BoldFont=思源黑体]{思源宋体}
  %\setCJKsansfont{思源黑体}
}
\AtBeginDocument{
  \IfExamBoolT{sourcehan}{
    \ifbool{XeTeX}{\rdxm@chinese@sourcehan}{
      \ifbool{LuaTeX}{\rdxm@chinese@sourcehan}{}
    }
  }
}

%% 这里不能用 \ifbool，因为涉及到 catcode 的改变
\ifexam@solidot
  \ifXeTeX
    \catcode`。=\active\def。{．}
    \else\ifLuaTeX
      \catcode`。=\active\def。{．}
    \fi
  \fi
\fi

%% Chinese translations of keywords
\DeclareExamTranslation{chinese}{
   answertable-Answer   = 答案
  ,answertable-Number   = 小题
  ,examdata-Appendix    = 附录
  ,exampart-Part        = {第,部分}
  ,examtitle-Name       = 姓名
  ,examtitle-Solutions  = 试卷解答
  ,gradetable-Evaluator = 评阅人
  ,gradetable-Part      = 部分
  ,gradetable-Score     = 得分
  ,gradetable-Total     = 总分
  ,headfoot-Name        = 姓名
  ,headfoot-of          = {共,页}
  ,headfoot-Page        = {第,页}
  ,headfoot-Solutions   = 试卷解答
  ,headfoot-Version     = {\relax,卷}
  ,points-point         = 分
  ,points-points        = 分
  ,question-Question    = 题
  ,solution-Solution    = 解
}
\IfExamBoolT{ctex}{\SelectExamTranslation{chinese}}

%% ---------------------------------------------------------------------------
%% Stop ignoring spaces in the code
%% ---------------------------------------------------------------------------

\IgnoreSpacesOff

