---
layout: post
title: "Building a Seriously Smart PDF Analyzer"
subtitle: "From text extraction to multimodal understanding in one modular system"
date: 2025-08-26
---

PDFs are everywhere—academic papers, business reports, legal documents, technical specs. They're also notoriously annoying to work with programmatically. I built an AI-enhanced PDF analyzer that goes beyond text extraction to actually understand documents.

## The Feature Stack

The analyzer handles seven core capabilities:

1. **Full text extraction** (PyMuPDF, no truncation)
2. **Mathematical expression detection** (regex + AI classification)
3. **Named Entity Recognition** (spaCy with 15+ entity types)
4. **Intelligent summarization** (OpenAI or fallback BART)
5. **Image extraction and analysis** (multimodal AI)
6. **Document type detection** (academic, technical, business, legal)
7. **Visualization generation** (entity charts, highlighted pages)

Each feature is modular. Use what you need, ignore what you don't.

## Progressive Enhancement Architecture

The system degrades gracefully based on available resources:

```python
class PDFAnalyzer:
    def __init__(self):
        # Try OpenAI first
        if os.getenv("OPENAI_API_KEY"):
            self.llm = ChatOpenAI(model="gpt-3.5-turbo")
        else:
            self.llm = None

        # Fall back to BART for summarization
        if self.llm is None:
            try:
                self.fallback_summarizer = pipeline("summarization",
                    model="facebook/bart-large-cnn")
            except:
                self.fallback_summarizer = None

    def summarize(self, text: str) -> str:
        if self.llm:
            return self.llm_summarize(text)
        elif self.fallback_summarizer:
            return self.bart_summarize(text)
        else:
            return self.extractive_summarize(text)  # Basic fallback
```

No API key? Local BART model runs fine. No GPU? Extractive summarization still works. The system always produces something useful.

## Smart Text Selection

Long documents don't fit in context windows. Naive truncation loses important information. I built a smarter selection algorithm:

```python
def smart_text_selection(self, full_text: str, max_tokens: int = 4000) -> str:
    sections = self.split_into_sections(full_text)

    selected = []
    token_budget = max_tokens

    # Priority 1: Abstract/Summary (if exists)
    abstract = self.find_abstract(sections)
    if abstract:
        selected.append(abstract)
        token_budget -= self.count_tokens(abstract)

    # Priority 2: Introduction
    intro = sections[0] if sections else ""
    selected.append(intro[:token_budget // 4])

    # Priority 3: Conclusion
    conclusion = sections[-1] if sections else ""
    selected.append(conclusion[:token_budget // 4])

    # Priority 4: Sample from middle
    middle_budget = token_budget // 2
    middle_sections = sections[1:-1]
    for section in self.sample_evenly(middle_sections):
        if self.count_tokens(section) < middle_budget:
            selected.append(section)
            middle_budget -= self.count_tokens(section)

    return "\n\n".join(selected)
```

This preserves the document's structure and key points even when space is limited.

## Mathematical Expression Detection

Academic papers are full of equations. Detecting them requires both pattern matching and intelligence:

```python
MATH_PATTERNS = [
    r'\$\$.*?\$\$',           # LaTeX display math
    r'\$.*?\$',               # LaTeX inline math
    r'\\begin\{equation\}.*?\\end\{equation\}',
    r'[a-zA-Z]\s*=\s*[^,\n]+',  # Simple equations
    r'\d+\s*[+\-*/^]\s*\d+',    # Arithmetic
    r'∑|∏|∫|∂|∇|√',            # Math symbols
]

def extract_math_expressions(self, text: str) -> List[MathExpression]:
    expressions = []
    for pattern in MATH_PATTERNS:
        matches = re.findall(pattern, text)
        expressions.extend(matches)

    # AI classification for complexity and domain
    if self.llm and expressions:
        classified = self.classify_expressions(expressions)
        return classified

    return [MathExpression(expr=e, domain="unknown") for e in expressions]
```

The AI classification adds context: Is this calculus or statistics? Undergraduate or graduate level? What concepts does it involve?

## Multimodal Understanding

Many PDFs contain crucial visual information—architecture diagrams, performance graphs, workflow charts. Text extraction misses all of it.

```python
class MultimodalPDFAnalyzer(PDFAnalyzer):
    def extract_and_analyze_images(self, pdf_path: str) -> List[ImageAnalysis]:
        doc = fitz.open(pdf_path)
        analyses = []

        for page_num, page in enumerate(doc):
            images = page.get_images(full=True)
            for img in images:
                # Extract image
                pix = fitz.Pixmap(doc, img[0])
                img_bytes = pix.tobytes("png")

                # Analyze with vision model
                analysis = self.vision_client.analyze(
                    image=img_bytes,
                    prompt="Describe this figure from a technical document. "
                           "What information does it convey?"
                )

                analyses.append(ImageAnalysis(
                    page=page_num,
                    description=analysis,
                    image_bytes=img_bytes
                ))

        return analyses
```

Now the summary can reference figures: "Figure 3 shows the system architecture with three main components..."

## Document Type Awareness

Different document types need different analysis strategies:

```python
def detect_document_type(self, text: str) -> DocumentType:
    signals = {
        'academic': ['abstract', 'methodology', 'references', 'doi'],
        'technical': ['api', 'implementation', 'architecture', 'deployment'],
        'business': ['revenue', 'strategy', 'stakeholder', 'q1', 'fiscal'],
        'legal': ['whereas', 'hereby', 'plaintiff', 'jurisdiction']
    }

    scores = {}
    for doc_type, keywords in signals.items():
        score = sum(1 for kw in keywords if kw in text.lower())
        scores[doc_type] = score

    return max(scores, key=scores.get)
```

Academic papers get focus on methodology and findings. Technical docs emphasize architecture. The system adapts.

## The API Layer

FastAPI makes the analyzer accessible as a service:

```python
@app.post("/analyze")
async def analyze_pdf(file: UploadFile) -> AnalysisResult:
    content = await file.read()

    with tempfile.NamedTemporaryFile(suffix=".pdf") as tmp:
        tmp.write(content)
        tmp.flush()

        analyzer = PDFAnalyzer()
        result = analyzer.analyze_pdf(tmp.name)

    return result

@app.post("/analyze-advanced")
async def analyze_advanced(file: UploadFile) -> AdvancedResult:
    # Same extraction, plus:
    # - Multimodal image analysis
    # - OCR math extraction from figures
    # - Entity relationship visualization
    # - Document type-specific insights
    ...
```

Two endpoints: standard analysis for quick results, advanced for full capabilities.

## What I Learned

**Modularity enables flexibility.** By keeping features separate, users can choose their complexity level. Simple use cases stay simple.

**Fallbacks matter.** Not everyone has API keys. Not every machine has a GPU. Systems that work in constrained environments get used more.

**Documents are more than text.** Images, tables, equations—they all carry information. Text-only analysis misses crucial context.

---

*Built with PyMuPDF, spaCy, OpenAI, and the belief that documents should be as easy to query as databases.*
