% -*- coding: utf-8 -*-
% ----------------------------------------------------------------------------
% Author:  Jianrui Lyu <tolvjr@163.com>
% License: The LaTeX Project Public License 1.3c
% ----------------------------------------------------------------------------

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{randexam}[2024-01-28 v2024C Make an exam paper and its randomized variants]

%% Old LaTeX release could not recognize date format like 2022-11-01
%\@ifl@t@r\fmtversion{2022-11-01}{}{
\@ifl@t@r\fmtversion{2022/11/01}{}{
  \ClassError{randexam}{%
    Your current TeX distribution is quite old.\MessageBreak
    We need CTeX 3.0+ or MiKTeX 2023+ or TeXLive 2023+%
  }{Please update your TeX distribution first.}
}

\RequirePackage{functional}
\IgnoreSpacesOn

\RequirePackage{etoolbox}

\newbool{plain}       \boolfalse{plain}      % use plain page style
\newbool{twoinone}    \boolfalse{twoinone}   % use A3 paper
\newbool{oneside}     \boolfalse{oneside}    % use single sided exam paper
\newbool{resetnumber} \booltrue{resetnumber} % reset numbers in new exam groups
\newbool{random}      \boolfalse{random}     % shuffle questions
\newbool{answer}      \booltrue{answer}      % show answers
\newbool{amsfonts}    \boolfalse{amsfonts}   % use ams fonts
\newbool{freealign}   \boolfalse{freealign}  % load freealign package
\newbool{medmath}     \boolfalse{medmath}    % use medium-size formulas
\newbool{evaluator}   \boolfalse{evaluator}  % add evaluator line in the grade table

\DeclareKeys{
  plain     .if    = plain,
  a3paper   .if    = twoinone,
  a3input   .code  = \booltrue{twoinone}\booltrue{plain},
  oneside   .if    = oneside,
  random    .if    = random,
  noanswer  .ifnot = answer,
  amsfonts  .if    = amsfonts,
  freealign .if    = freealign,
  medmath   .if    = medmath,
  evaluator .if    = evaluator,
  many      .code  = \booltrue{freealign},
  most      .code  = \booltrue{freealign}\booltrue{medmath}
}

\DeclareUnknownKeyHandler{\PassOptionsToClass{\CurrentOption}{article}}

\ProcessKeyOptions

\LoadClass{article}

\iftwoinone
  \RequirePackage[a3paper,landscape,twocolumn,columnsep=60mm,left=30mm,right=30mm,top=25mm,bottom=25mm]{geometry}
\else
  \RequirePackage[a4paper,left=30mm,right=30mm,top=25mm,bottom=25mm]{geometry}
\fi

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

\ifplain
  \allowdisplaybreaks[4]
\fi

\ifamsfonts
  \RequirePackage{amssymb}
\else
  \RequirePackage[utopia]{mathdesign} % charter, utopia
  \renewcommand\bfdefault{bx}
  \let\oldoiint\oiint\renewcommand{\oiint}{\oldoiint\nolimits}
  \DeclareTextCommandDefault{\nobreakspace}{\leavevmode\nobreak\ }
\fi

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
  \ignorespaces
}

%% #1: exam element; #2: template name
\NewDocumentCommand\SelectExamTemplate{mm}{
  \tlSetEq{\expName{l@rdxm@template@#1@default@tl}}{\expName{l@rdxm@template@#1@#2@tl}}
  \ignorespaces
}

%% #1: exam element; #2: template name.
%% In an expandable command, we should use \UseName but not \expName.
\NewExpandableDocumentCommand\UseExamTemplate{mm}{
  \UseName{l@rdxm@template@#1@#2@tl}
}

%% ---------------------------------------------------------------------------
%% Translation commands for exam keywords
%% ---------------------------------------------------------------------------

\tlSet\l@rdxm@current@language@tl{english}

\DeclareUnknownKeyHandler[randexam-translation]{
  \tlSet{\expName{l@rdxm@translate@\l@rdxm@declare@language@tl @#1@tl}}{#2}
}

%% #1: language name; #2: a keyval list with keyword = transaltion format
\NewDocumentCommand\DeclareExamTranslation{mm}{
  \tlIfEqTF{#1}{current}{
    \tlSetEq\l@rdxm@declare@language@tl\l@rdxm@current@language@tl
  }{
    \tlSet\l@rdxm@declare@language@tl{#1}
  }
  \SetKeys[randexam-translation]{#2}
  \ignorespaces
}

%% #1: language name
\NewDocumentCommand\SelectExamTranslation{m}{
  \tlSet\l@rdxm@current@language@tl{#1}
  \ignorespaces
}

%% #1: keyword name.
%% In an expandable command, we should use \UseName but not \expName.
\NewExpandableDocumentCommand\UseExamTranslation{m}{
  \UseName{l@rdxm@translate@\l@rdxm@current@language@tl @#1@tl}
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

\SelectExamTranslation{english}

%% ---------------------------------------------------------------------------
%% Keyvalue commands for exam options
%% ---------------------------------------------------------------------------

%% #1 module name; #2: key name; #3: its value
\NewDocumentCommand\DeclareExamValue{mm+m}{
  \tlSet{\expName{l@rdxm@value@#1@#2@tl}}{#3}
  \ignorespaces
}

%% #1: module name; #2: key name.
%% In an expandable command, we should use \UseName but not \expName.
\NewExpandableDocumentCommand\UseExamValue{mm}{
  \UseName{l@rdxm@value@#1@#2@tl}
}

%% ---------------------------------------------------------------------------
%% Command for exam title: \examtitle
%% ---------------------------------------------------------------------------

\newcommand{\underspace}[1]{\kern0pt\underline{\hspace{#1}}\kern0pt\relax}
\newcommand{\underbox}[2]{\kern0pt\underline{\makebox[#1]{#2}}\kern0pt\relax}
\newcommand{\underparbox}[2]{\kern0pt\underline{\parbox[b]{#1}{#2}}\kern0pt\relax}

\newcommand{\ischeck}[1]{\ifnum#1>0\,$\checkmark$\,\else\quad\fi}
\newcommand{\isquad}[1]{\ifnum#1=0\,$\checkmark$\,\else\quad\fi}

\DeclareKeys[randexam-title]{
   name    .code = \DeclareExamValue{examtitle}{name}{#1}
  ,date    .code = \DeclareExamValue{examtitle}{date}{#1}
  ,version .code = \DeclareExamValue{examtitle}{version}{#1}
}

\NewDocumentCommand\SetExamTitle{+m}{\SetKeys[randexam-title]{#1}}

\SetExamTitle{name=Math~1906,date=\today,version=A}

\DeclareExamTemplate{examtitle}{normal}{
  \begingroup
  \Large\noindent
  \ifbool{answer}{
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
  \SetExamTitle{#1}
  \thispagestyle{plain}
  \ifbool{random}{
    \tlIfEqT{\expWhole{\UseExamValue{examtitle}{version}}}{A}{
      \DeclareExamValue{examtitle}{version}{B}
    }
    \tlIfEqT{\expWhole{\UseExamValue{examtitle}{version}}}{C}{
      \DeclareExamValue{examtitle}{version}{D}
    }
  }{}
  \UseExamTemplate{examtitle}{default}
}

%% ---------------------------------------------------------------------------
%% Command for grade table: \gradetable
%% ---------------------------------------------------------------------------

%% total: total number of parts in current exam;
%% strut: strut height in the score row.
\DeclareKeys[randexam-gradetable]{
   total  .code      = \DeclareExamValue{gradetable}{total}{#1}
  ,total  .initial:n = 6
  ,strut  .code      = \DeclareExamValue{gradetable}{strut}{#1}
  ,strut  .initial:n = 2.5em
}

\newcounter{@exam@grade@cnt}
\newrobustcmd\rdxm@part@number[1]{
  \setcounter{@exam@grade@cnt}{#1}
  \exam@part@number{@exam@grade@cnt}
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
  \ifbool{evaluator}{
    \rdxm@table@make@row
      \l@rdxm@gradetable@evaluator@tl
      {\textbf{\UseExamTranslation{gradetable-Evaluator}}
           \MakeExamStruct{\UseExamValue{gradetable}{strut}}}
      {}
      {\UseExamValue{gradetable}{total}}
      \rdxm@gobble@one
  }{}
  \noindent
  \begin{tabularx}{\linewidth}{|c|*{\UseExamValue{gradetable}{total}}{Y|}Y|}
    \hline
    \l@rdxm@gradetable@part@tl \\ \hline
    \l@rdxm@gradetable@score@tl \\ \hline
    \ifbool{evaluator}{\l@rdxm@gradetable@evaluator@tl \\ \hline}{}
  \end{tabularx}
}
\SelectExamTemplate{gradetable}{normal}

\NewDocumentCommand\gradetable{O{}}{
  \par\vspace{1em}
  \begingroup
  \SetKeys[randexam-gradetable]{#1}
  \UseExamTemplate{gradetable}{default}
  \endgroup
}

%% ---------------------------------------------------------------------------
%% Setting header and footer
%% ---------------------------------------------------------------------------

\newcommand{\rdxm@columnbox}[1]{\makebox[\columnwidth]{#1}}
\newcommand{\rdxm@headleft}{\UseExamValue{examtitle}{name}}
\newcommand{\rdxm@headright}{
  \ifbool{answer}{
    \UseExamTranslation{headfoot-Solutions}
  }{
    \UseExamTranslation{headfoot-Name}:\hspace{12em}
  }
}
\newcommand{\rdxm@headtext}{\rdxm@headleft\hfill\rdxm@headright}
\newcommand{\rdxm@footleft}{\UseExamValue{examtitle}{date}}
\newcommand{\rdxm@footcenter}{
  \UseExamTranslation{headfoot-Page}~\thepage\space
  \UseExamTranslation{headfoot-of}~\zpageref{LastPage}
}
\newcommand{\rdxm@footright}{
  \UseExamTranslation{headfoot-Version}~\UseExamValue{examtitle}{version}
}
\newcommand{\rdxm@foottext}{\rdxm@footleft\hfill\rdxm@footcenter\hfill\rdxm@footright}

% fancy page style
\fancyhf{} % clear head and foot
\iftwoinone
  \renewcommand{\headrulewidth}{0pt}%
  \lhead{\small\underline{\rdxm@columnbox{\rdxm@headtext}\strut}}
  \rhead{\small\underline{\rdxm@columnbox{\rdxm@headtext}\strut}}
  \lfoot{\small\rdxm@columnbox{\rdxm@foottext}}
  \rfoot{\small\rdxm@columnbox{\stepcounter{page}\rdxm@foottext}}
\else
  \lhead{\small\rdxm@headleft}
  \rhead{\small\rdxm@headright}
  \cfoot{\small\rdxm@foottext}
\fi

% plain page style
\fancypagestyle{plain}{
  \renewcommand{\headrulewidth}{0pt}%
  \fancyhf{}
  \iftwoinone
    \rhead{\small\underline{\rdxm@columnbox{\rdxm@headtext\strut}}}
    \lfoot{\small\rdxm@columnbox{\rdxm@foottext}}
    \rfoot{\small\rdxm@columnbox{\stepcounter{page}\rdxm@foottext}}
  \else
    \cfoot{\small\rdxm@foottext}
  \fi
}

\ifplain
  \pagestyle{plain}
\else
  \pagestyle{fancy}
\fi

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

\ifrandom
  \RequirePackage{pgf}
  \RequirePackage{pgffor}
  \newcommand*\exam@set@seed{%
    %% 当\pgfmathrandom的参数为3的倍数时，对相邻种子生成的多个随机数分布不均匀
    %\pgfmathsetseed{\numexpr\rdxm@random@seed+\value{rdxm@part}-1\relax}%
    %% 因此我们改用下面的方法，用随机数种子生成下一个随机数种子
    \pgfmathsetseed{\rdxm@random@seed}%
    \pgfmathrandominteger\rdxm@random@seed{1}{2147483647}%
  }
\fi

%% ---------------------------------------------------------------------------
%% Command for exam groups: \exampart
%% Command for appendix data: \examdata
%% Environment for questions: question
%% Environment for solutions: solution
%% ---------------------------------------------------------------------------

%% You need to put .code before .initial:n
\DeclareKeys[randexam-exampart]{%
  partnumber .code      = \let\exam@part@number#1,
  partnumber .initial:n = \Roman,
}

\newif\ifonlyonequestion \onlyonequestionfalse % 此部分仅有一道题时不显示题目编号
\xdef\allquestions{}
\xdef\lastquestion{}
\newcounter{question}        % 当前题型的小题编号
\newcounter{questionreal}    % 实际显示的小题编号，在各题型小题统一编号时使用
\newcounter{totalquestions}  % 之前各题型小题总数，在各题型小题统一编号时使用

\newcounter{choice} % 后面选择题的 abcd 环境要用到
\newcommand{\hangtext}{}
\newlength{\hanglength}
\colorlet{part~number}{black}
\colorlet{question~number}{blue!80!black}
\colorlet{solution~name}{blue!80!black}

\newcounter{rdxm@shuffle@temp@cnt}
\newcounter{rdxm@list@temp@cnt}

\newcommand\rdxm@list@print[1]{%
  \par\renewcommand*{\do}[1]{(##1)}%
  \dolistloop#1%
}

\newcommand\rdxm@list@remove[2]{%
  %\rdxm@list@print\rdxm@shuffle@list
  \setcounter{rdxm@list@temp@cnt}{0}%
  \global\let\rdxm@tmpa@list=#1%
  \gdef#1{}%
  \par\renewcommand*{\do}[1]{%
    \stepcounter{rdxm@list@temp@cnt}%
    \ifnumequal{\value{rdxm@list@temp@cnt}}{#2}{%
      \def\rdxm@list@item{##1}%
      %[##1]%
    }{
      \listxadd#1{##1}%
    }%
  }%
  \dolistloop\rdxm@tmpa@list
}

\newcommand\rdxm@shuffle@questions{%
  \exam@set@seed
  \ifnumgreater{\value{question}}{2}{%
    \gdef\rdxm@shuffle@list{}%
    \foreach \i in {1,...,\value{question}} {\listxadd\rdxm@shuffle@list{\i}}%
    %% 首尾两个小题的位置总要改变
    \pgfmathrandom{2,\value{question}}%
    \rdxm@list@remove\rdxm@shuffle@list{\pgfmathresult}%
    \global\csletcs{rdxm@question@b@1}{rdxm@question@a@\rdxm@list@item}%
    \ifnumequal{\rdxm@list@item}{\value{question}}{
      \pgfmathrandom{\numexpr\value{question}-1\relax}%
      \rdxm@list@remove\rdxm@shuffle@list{\pgfmathresult}%
      \global\csletcs{rdxm@question@b@\the\value{question}}{rdxm@question@a@\rdxm@list@item}%
    }{%
      \pgfmathrandom{\numexpr\value{question}-2\relax}%
      \rdxm@list@remove\rdxm@shuffle@list{\pgfmathresult}%
      \global\csletcs{rdxm@question@b@\the\value{question}}{rdxm@question@a@\rdxm@list@item}%
    }%
    %% 其他小题的位置没有任何限制
    \setcounter{rdxm@shuffle@temp@cnt}{1}%
    \whileboolexpr{%
      test{\ifnumless{\value{rdxm@shuffle@temp@cnt}}{\numexpr\value{question}-1\relax}}%
    }{%
      \stepcounter{rdxm@shuffle@temp@cnt}%
      \pgfmathrandom{\numexpr\value{question}-\value{rdxm@shuffle@temp@cnt}\relax}%
      \rdxm@list@remove\rdxm@shuffle@list{\pgfmathresult}%
      \global\csletcs{rdxm@question@b@\the\value{rdxm@shuffle@temp@cnt}}{%
        rdxm@question@a@\rdxm@list@item
      }%
    }%
  }{%
    \ifnumequal{\value{question}}{2}{%
      \global\csletcs{rdxm@question@b@1}{rdxm@question@a@2}%
      \global\csletcs{rdxm@question@b@2}{rdxm@question@a@1}%
    }{}%
  }%
}

\newcommand{\printquestions}{%
  \ifrandom
    \rdxm@appto@questions
    \rdxm@shuffle@questions
    \setcounter{question}{0}%
    \allquestions
  \fi
  \xdef\allquestions{}%
  \xdef\lastquestion{}%
}

\newcounter{rdxm@part}

\DeclareExamTemplate{exampart}{normal}{
  \noindent
  \textbf{
    \textcolor{part~number}{\UseExamTranslation{exampart-Part}~\Roman{rdxm@part}}
    :~\UseExamValue{exampart}{type}
  }
  \space(\UseExamValue{exampart}{points})
}
\SelectExamTemplate{exampart}{normal}

\newcommand{\exampart}[2]{
  \printquestions
  \setcounter{totalquestions}{\value{totalquestions}+\value{question}}
  \setcounter{question}{0}
  \stepcounter{rdxm@part}
  \vspace{1em}
  \begingroup
  \DeclareExamValue{exampart}{type}{#1}
  \DeclareExamValue{exampart}{points}{#2}
  \UseExamTemplate{exampart}{default}
  \endgroup
  \par\nopagebreak
  \if\relax\detokenize{#1}\relax % #1 is empty
    \onlyonequestiontrue
  \else
    \onlyonequestionfalse
    \vspace{1em}%
  \fi
  %其中设定了\@nobreaktrue，保证在列表前也不分页，详情见 source2e
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
  \DeclareExamValue{examdata}{caption}{#1}
  \UseExamTemplate{examdata}{default}
}

\preto{\@enddocumenthook}{\printquestions\rdxm@stop@random}

\newcommand\ignorepars{\@ifnextchar\par{\expandafter\ignorepars\@gobble}{}}

% local definition, valid only in current question
\DeclareKeys[randexam-question]{
   points .store = \l@rdxm@question@points
  ,level  .store = \l@rdxm@question@level
  ,year   .store = \l@rdxm@question@year
}

\newcommand\pointorpoints[1]{
  \ifnumgreater{#1}{1}{
    \UseExamTranslation{points-points}
  }{
    \UseExamTranslation{points-point}
  }
}

\newcommand{\questionpointstext}[1]{ (#1 \pointorpoints{#1}) }

\newcommand\rdxm@hook@exec@other@keys{}

\newrobustcmd\execute@question@keys{
  \rdxm@hook@exec@other@keys
  \ifdefvoid{\l@rdxm@question@points}{}{\questionpointstext{\l@rdxm@question@points}}
}

\DeclareExamTemplate{questionbegin}{normal}{
  \ifresetnumber
    \ifonlyonequestion
      \renewcommand{\hangtext}{\qquad}%
    \else
      \renewcommand{\hangtext}{\textbf{\textsf{\textcolor{question~number}{\arabic{question}}.}}\;\,}
    \fi
  \else
    \setcounter{questionreal}{\value{totalquestions}+\value{question}}%
    \renewcommand{\hangtext}{\textbf{\textsf{\textcolor{question~number}{\arabic{questionreal}}.}}\;\,}
  \fi
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
  \SetKeys[randexam-question]{#1}
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

\ifrandom
  \newcommand\rdxm@appto@questions{%
    \xappto\allquestions{\expandonce\lastquestion}%
  }%
  \NewEnviron{question}{%
    \stepcounter{question}%
    \rdxm@appto@questions
    \csxdef{rdxm@question@a@\the\value{question}}{%
      \unexpanded{\begin{questionreal}}%
      \unexpanded\expandafter{\BODY}%
      \unexpanded{\end{questionreal}}%
    }%
    \csxdef{rdxm@question@b@\the\value{question}}{%
      \expandonce{\csname rdxm@question@a@\the\value{question}\endcsname}%
    }%
    \xdef\lastquestion{%
      \expandonce{\csname rdxm@question@b@\the\value{question}\endcsname}%
    }%
  }
  \NewEnviron{solution}{%
    \csxappto{rdxm@question@a@\the\value{question}}{%
      \unexpanded{\begin{solutionreal}}%
      \expandonce{\BODY}%
      \unexpanded{\end{solutionreal}}%
    }%
  }
  \renewcommand{\newpage}{\gappto\lastquestion{\oldnewpage}}
  \renewcommand{\vfill}{\csgappto{rdxm@question@a@\the\value{question}}{\oldvfill}}
  \renewcommand{\smallskip}{\csgappto{rdxm@question@a@\the\value{question}}{\oldsmallskip}}
  \renewcommand{\medskip}{\csgappto{rdxm@question@a@\the\value{question}}{\oldmedskip}}
  \renewcommand{\bigskip}{\csgappto{rdxm@question@a@\the\value{question}}{\oldbigskip}}
\else
  \newenvironment{question}[1][]{\questionreal[#1]}{\endquestionreal}
  %\newenvironment{solution}{\solutionreal}{\endsolutionreal}
  \NewEnviron{solution}{\begin{solutionreal}\BODY\end{solutionreal}}
\fi

\newcommand{\rdxm@stop@random}{%
  \ifrandom
    \renewenvironment{question}{\questionreal}{\endquestionreal}%
    \renewenvironment{solution}{\solutionreal}{\endsolutionreal}%
    \let \newpage   = \oldnewpage
    \let \vfill     = \oldvfill
    \let \smallskip = \oldsmallskip
    \let \medskip   = \oldmedskip
    \let \bigskip   = \oldbigskip
  \fi
}

\def\CommentCutFile{\jobname.cut}

\AtBeginDocument{%
  \ifanswer\else
    \excludecomment{solution}
  \fi
}

%% ---------------------------------------------------------------------------
%% Command for answer tables: \answertable
%% ---------------------------------------------------------------------------

%% property .store is the same as .tl_set:N in ltkeys.
%% you need to put .code before .initial:n.
%% total: total number of questions in current exam part;
%% column: number of questions in each answer row;
%% strut: strut height in each answer rows;
%% notice: notice text before the answer table.
\DeclareKeys[randexam-answertable]{
   total  .code      = \DeclareExamValue{answertable}{total}{#1}
  ,column .code      = \DeclareExamValue{answertable}{column}{#1}
  ,strut  .code      = \DeclareExamValue{answertable}{strut}{#1}
  ,strut  .initial:n = 1em
  ,notice .code      = \DeclareExamValue{answertable}{notice}{#1}
  ,notice .initial:n = {Notice:~you~MUST~write~the~answers~in~the~following~tables.}
}

\gdef\answer@lines@temp{}%
\newcommand{\answer@lines@add}[1]{%
  \xdef\answer@lines@temp{\answer@lines@temp#1}%
}

\newrobustcmd\answer@number@hided[1]{\UseExamTranslation{answertable-Number}}
\newrobustcmd\answer@cell@strut[1]{
  \parbox[c][#1][c]{2em}{\hbox{\UseExamTranslation{answertable-Answer}}}
}

\newcounter{answer@col}
\newcounter{answer@row}
\newcounter{answer@total}

%% #1: strut; #2: total; #3: column.
\newcommand{\answer@lines}[3]{%
  \setcounter{answer@row}{(#2-1)/#3+1}% 除法向下取整，改为向上取整
  \begingroup
  \let\hline=\relax  \let\\=\relax % 禁止展开
  \gdef\answer@lines@temp{}%
  \setcounter{answer@total}{1}%
  \whileboolexpr{
      test{\ifnumgreater{\value{answer@row}}{0}}
  }{%
      \addtocounter{answer@row}{-1}%
      \answer@lines@add{\answer@number@hided}%
      \setcounter{answer@col}{1}%
      \unlessboolexpr{%
          test{\ifnumgreater{\value{answer@col}}{#3}}%
      }{%
          \answer@lines@add{&}%
          \ifnumgreater{\value{answer@total}}{#2}{}{%
            \answer@lines@add{\arabic{answer@total}}%
          }%
          \stepcounter{answer@col}%
          \stepcounter{answer@total}%
      }%
      \answer@lines@add{\\ \hline \answer@cell@strut{#1}}%
      \setcounter{answer@col}{1}%
      \unlessboolexpr{
          test{\ifnumgreater{\value{answer@col}}{#3}}
      }{%
          \answer@lines@add{&}%
          \stepcounter{answer@col}%
      }%
      \answer@lines@add{\\ \hline}%
  }%
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
  \SetKeys[randexam-answertable]{#1}
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

\newcommand{\answer}[1]{\ifanswer#1\else\phantom{#1}\fi}

\newcommand*{\cdotfill}{\leavevmode\xleaders\hbox to 0.5em{\hss$\cdot$\hss}\hfill\kern0pt\relax}

\newcommand*{\tick@box}[1]{[\makebox[1.5em]{\color{blue}\answer{#1}}]}
\newcommand*{\tick@text@t}{$\checkmark$}
\newcommand*{\tick@text@f}{{\large$\times$}}
\newcommand*{\tick@text@T}{\sffamily T}
\newcommand*{\tick@text@F}{\sffamily F}
\newcommand*{\tickin}[1]{\tick@box{\csname tick@text@#1\endcsname}}
\newcommand*{\tickout}[1]{\unskip\nobreak\cdotfill\tick@box{\csname tick@text@#1\endcsname}}

\newcommand*{\ulinefill}[1]{\xleaders\hbox{\underline{\vphantom{#1}\kern1pt}}\hfill\kern0pt}
\newcommand*{\minwidthbox}[2]{\makebox[{\ifdim#1<\width\width\else#1\fi}]{#2}}

\newcommand*{\fillout}[1]{\allowbreak\hbox{}\nobreak\ulinefill{#1}\underline{\color{blue}\answer{#1}}\ulinefill{#1}}
\newcommand*{\fillin}[1]{\underline{\hspace{1em}\color{blue}\minwidthbox{2em}{\answer{#1}}\hspace{1em}}}

\newcommand*\pickoutreal[1]{%
  \unskip\nobreak\cdotfill(\makebox[1.5em]{\color{blue}\answer{#1}})%
}
\newcommand*\pickinreal[1]{%
  \unskip\nobreak
  \hspace{0.3em}(\makebox[1.5em]{\color{blue}\answer{#1}})\hspace{0.3em}%
  \ignorespaces
}

%% 选择题四个选项打乱顺序，用三种方法即可保证答案不同
%% 1：ABCD -> CDAB； 2：ABCD -> BADC; 3: ABCD -> DCBA
%% 即在两行排列时仅用到上下交换以及左右交换，这样可以保持两行长度不变

\csdef{rdxm@shuffle@1@A}{C} \csdef{rdxm@shuffle@2@A}{B} \csdef{rdxm@shuffle@3@A}{D}
\csdef{rdxm@shuffle@1@B}{D} \csdef{rdxm@shuffle@2@B}{A} \csdef{rdxm@shuffle@3@B}{C}
\csdef{rdxm@shuffle@1@C}{A} \csdef{rdxm@shuffle@2@C}{D} \csdef{rdxm@shuffle@3@C}{B}
\csdef{rdxm@shuffle@1@D}{B} \csdef{rdxm@shuffle@2@D}{C} \csdef{rdxm@shuffle@3@D}{A}

\def\@rdxm@choice@random{0}
\newcommand\rdxm@shuffle@abcd[1]{\csuse{rdxm@shuffle@\@rdxm@choice@random @#1}}

\newcommand*\pickout[1]{%
  \ifbool{random}{%
    \exam@set@seed
    \pgfmathrandominteger\@rdxm@choice@random{1}{3}%
    %\@rdxm@choice@random
    \pickoutreal{\rdxm@shuffle@abcd{#1}}%
  }{%
    \pickoutreal{#1}%
  }%
}
\newcommand*\pickoutfixed[1]{%
  \pickoutreal{#1}%
  \randomfalse
}
\newcommand*\pickin[1]{%
  \ifbool{random}{%
    \exam@set@seed
    \pgfmathrandominteger\@rdxm@choice@random{1}{3}%
    %\@rdxm@choice@random
    \pickinreal{\rdxm@shuffle@abcd{#1}}%
  }{%
    \pickinreal{#1}%
  }%
}
\newcommand*\pickinfixed[1]{%
  \pickinreal{#1}%
  \randomfalse
}

%% ---------------------------------------------------------------------------
%% Environment abcd for typesetting options of multiple-choice questions
%% Put them in one, two, or four rows according to the lengths of the choices
%% ---------------------------------------------------------------------------

\newlength{\rdxm@item@len}
\newlength{\rdxm@label@len}

\newcommand\rdxm@item@temp{%
  \unskip\cr\stepcounter{choice}(\Alph{choice})\ %
}
\newcommand\rdxm@item@box{%
  \hfill\egroup\hfill\hbox to \rdxm@item@len\bgroup
  \stepcounter{choice}(\Alph{choice})\ \ignorespaces
}
\newcommand\rdxm@item@par{%
  \stepcounter{choice}%
  \def\rdxm@label@text{(\Alph{choice})\ }%
  \settowidth{\rdxm@label@len}{\rdxm@label@text}%
  \par \parshape 2 \hanglength \linewidth
  \dimexpr\hanglength + \rdxm@label@len\relax
  \dimexpr\linewidth - \rdxm@label@len\relax
  \rdxm@label@text\ignorespaces
}

\NewEnviron{abcdreal}{
  \unskip
  \setlength{\parindent}{0pt}%
  \setlength{\parskip}{0pt}%
  \setcounter{choice}{0}%
  \let\item=\rdxm@item@temp
  \settowidth{\rdxm@item@len}{\vbox{\halign{##\hfil\cr\BODY\crcr}}}%
  \setcounter{choice}{0}%
  \ifdim\rdxm@item@len>0.486\linewidth
    \setlength{\rdxm@item@len}{\linewidth}%
    \let\item=\rdxm@item@par
    \BODY\par
  \else
    \ifdim\rdxm@item@len>.243\linewidth
      \setlength{\rdxm@item@len}{0.5\linewidth}%
    \else
      \setlength{\rdxm@item@len}{0.25\linewidth}%
    \fi
    \let\item=\rdxm@item@box
    \par\bgroup\BODY\hfill\egroup\par
  \fi
}

\newcommand\rdxm@item@one@line{%
  \unskip
  \ifnumequal{\value{choice}}{0}{}{\hfill}
  \stepcounter{choice}(\Alph{choice})\ %
}
\newcommand\rdxm@item@two@line{%
  \unskip
  \ifnumodd{\value{choice}}{&}{\unskip\cr}%
  \stepcounter{choice}(\Alph{choice})\ %
}

\NewEnviron{abcd*real}{
  \unskip
  \setlength{\parindent}{0pt}%
  \setlength{\parskip}{0pt}%
  \setcounter{choice}{0}%
  \let\item=\rdxm@item@one@line
  \settowidth{\rdxm@item@len}{\BODY}%
  \ifdim\rdxm@item@len<0.95\linewidth
    \setcounter{choice}{0}%
    \par\bgroup\BODY\hfill\hfill\par\egroup\par
  \else
    \setcounter{choice}{0}%
    \let\item=\rdxm@item@two@line
    \settowidth{\rdxm@item@len}{\vbox{\halign{##&##\hfil\cr\BODY\crcr}}}%
    \ifdim\rdxm@item@len<0.975\linewidth
      \setcounter{choice}{0}%
      \par\bgroup\nointerlineskip
      \vbox{\halign to\linewidth{##\hfil\tabskip=0pt plus 1fil&##\hfil\cr\BODY\crcr}}%
      \egroup\par
    \else
      \setcounter{choice}{0}%
      \let\item=\rdxm@item@par
      \par\bgroup\BODY\hfill\egroup\par
    \fi
  \fi
}

\ifbool{random}{%
  \csdef{rdxm@swap@items@1}#1#2#3#4{\item#3\item#4\item#1\item#2}
  \csdef{rdxm@swap@items@2}#1#2#3#4{\item#2\item#1\item#4\item#3}
  \csdef{rdxm@swap@items@3}#1#2#3#4{\item#4\item#3\item#2\item#1}
  \long\def\rdxm@swap@items#1\item#2\item#3\item#4\item#5\@rdxm@stop@mark{%
    #1\csuse{rdxm@swap@items@\@rdxm@choice@random}{#2}{#3}{#4}{#5}%
  }
}{}

\NewDocumentEnvironment{abcd}{+b}{%
  \ifbool{random}{%
    \begin{abcdreal}\rdxm@swap@items#1\@rdxm@stop@mark\end{abcdreal}%
  }{%
    \begin{abcdreal}#1\end{abcdreal}%
  }%
}{}
\NewDocumentEnvironment{abcd*}{+b}{%
  \ifbool{random}{%
    \begin{abcd*real}\rdxm@swap@items#1\@rdxm@stop@mark\end{abcd*real}%
  }{%
    \begin{abcd*real}#1\end{abcd*real}%
  }%
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

\AtBeginDocument{%
  \ifbool{freealign}{\RequirePackage{freealign}}{}%
}

%% ---------------------------------------------------------------------------
%% Command for giving points in solutions: \points
%% ---------------------------------------------------------------------------

\PassOptionsToPackage{tbtags}{amsmath}
\RequirePackage{amsmath}

\newcommand{\solutionpointstext}[1]{%
  \textcolor{red}{#1\kern0.15em\pointorpoints{#1}}%
}

\newcommand{\pointstext}[1]{%
  \mbox{}\nobreak\hfill$\cdots\cdots$\solutionpointstext{#1}%
  \par\noindent\ignorespaces
}
\newcommand{\pointseqno}[1]{\eqno{\cdots\cdots\text{\solutionpointstext{#1}}}}
\newcommand{\pointstag}[1]{\tag*{$\cdots\cdots$\solutionpointstext{#1}}}

\newrobustcmd{\points}[1]{%
  \ifbool{mmode}{%
    \ifdefstrequal{\tag}{\dft@tag}{\pointseqno{#1}}{\pointstag{#1}}%
  }{%
    \pointstext{#1}%
  }%
}

%% ---------------------------------------------------------------------------
%% Use medium-size fractions and operators in both inline and displayed formulas
%% ---------------------------------------------------------------------------

\AtBeginDocument{%
  \ifbool{medmath}{\RequirePackage{medmath}}{}%
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

\setlength\arraycolsep{4pt}

\RequirePackage{diagbox}
%% 修正 \diagbox 在 array 环境中使用的问题
\newrobustcmd{\diagboxtwo}[3][]{%
  \ifbool{mmode}{%
    \hbox{\let\tabcolsep=\arraycolsep\diagbox[#1]{$#2$}{$#3$}}%
  }{%
    \diagbox[#1]{#2}{#3}%
  }
}
\newrobustcmd{\diagboxthree}[4][]{%
  \ifbool{mmode}{%
    \hbox{\let\tabcolsep=\arraycolsep\diagbox[#1]{$#2$}{$#3$}{$#4$}}%
  }{%
    \diagbox[#1]{#2}{#3}{#4}%
  }
}

\RequirePackage{mathtools} % \mathllap 命令，pmatrix* 环境等
\RequirePackage{extarrows}

\AtBeginDocument{%
  \let\rdxm@saved@lim=\lim    \def\lim{\rdxm@saved@lim\limits}%
  \let\rdxm@saved@sum=\sum    \def\sum{\rdxm@saved@sum\limits}%
  \let\rdxm@saved@prod=\prod  \def\prod{\rdxm@saved@prod\limits}%
}

\newcommand{\e}{\mathrm{e}}
\newcommand{\R}{\mathbb{R}}

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

\newcommand{\diff}{\mathop{}\!\mathrm{d}}
\newcommand{\dx}{\diff x}
\newcommand{\dy}{\diff y}
\def\dz{\diff z} % 不确定命令是否已经定义
\newcommand{\du}{\diff u}
\newcommand{\dv}{\diff v}
\newcommand{\dr}{\diff r}
\newcommand{\ds}{\diff s}
\newcommand{\dt}{\diff t}
\newcommand{\dS}{\diff S}
% 有些宏包比如 hyperref 会修改 \d 的定义，所以放在 document 开始处
% 利用 etoolbox 将 \d 定义为健壮命令，以避免在 align 等环境中错误地展开
\AtBeginDocument{%
  \let\oldd=\d
  \renewrobustcmd{\d}{\ifbool{mmode}{\diff}{\oldd}}%
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

% from mathabx package
\DeclareFontFamily{U}{mathx}{\hyphenchar\font45}
\DeclareFontShape{U}{mathx}{m}{n}{<-> mathx10}{}
\DeclareSymbolFont{mathx}{U}{mathx}{m}{n}
\DeclareMathAccent{\widebar}{0}{mathx}{"73}

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

\let\ov=\overrightarrow

\let\le=\leqslant
\let\ge=\geqslant

\let\lb=\{
\let\rb=\}

\def\T{\mathrm{T}\kern-.5pt}

% 分数线长一点的分数，\wfrac[2pt]{x}{y} 表示左右加 2pt
% 和前面的 medmath 一样，将代码放在 \AtBeginDocument 里
\AtBeginDocument{%
  \newrobustcmd{\wfrac}[3][2pt]{%
    \frac{\hspace{#1}#2\hspace{#1}}{\hspace{#1}#3\hspace{#1}}%
  }%
  \newrobustcmd{\wdfrac}[3][2pt]{%
    \dfrac{\hspace{#1}#2\hspace{#1}}{\hspace{#1}#3\hspace{#1}}%
  }%
  \newrobustcmd{\wtfrac}[3][2pt]{%
    \tfrac{\hspace{#1}#2\hspace{#1}}{\hspace{#1}#3\hspace{#1}}%
  }%
}

% 使用 stix font 中的 white arrows
\AtBeginDocument{\@ifpackageloaded{fontspec}{%
    %\IfFileExists{STIX-Regular.otf}{% 在 TeXLive 中无效
    \IfFileExists{stix.sty}{%
        \newfontfamily{\@rdxm@stix}{STIX} % stix v1.1
    }{%
        \newfontfamily{\@rdxm@stix}{STIXGeneral} % stix v1.0
    }
    \newrobustcmd\leftwhitearrow{%
      \mathrel{\text{\normalfont\@rdxm@stix\symbol{"21E6}}}%
    }
    \newrobustcmd\upwhitearrow{%
      \mathrel{\text{\normalfont\@rdxm@stix\symbol{"21E7}}}%
    }
    \newrobustcmd\rightwhitearrow{%
      \mathrel{\text{\normalfont\@rdxm@stix\symbol{"21E8}}}%
    }
    \newrobustcmd\downwhitearrow{%
      \mathrel{\text{\normalfont\@rdxm@stix\symbol{"21E9}}}%
    }
}{%
    \let \leftwhitearrow = \Leftarrow
    \let \rightwhitearrow = \Rightarrow
    \let \upwhitearrow = \Uparrow
    \let \downwhitearrow = \Downarrow
}}

\IgnoreSpacesOff

