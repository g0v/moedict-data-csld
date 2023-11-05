'use client';

import { useState } from 'react';
import './page.scss';

interface TermsFoundResponse {
  terms: { [key: string]: number[] };
}
const CheckerPage = () => {
  const [text, setText] = useState('');
  const [results, setResults] = useState<TermsFoundResponse>({ terms: {} });
  const [cursorPosition, setCursorPosition] = useState(0);
  const [error, setError] = useState('');

  const handleTextareaChange = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
    setText(e.target.value);
  };

  const handleTextareaClick = (e: React.MouseEvent<HTMLTextAreaElement>) => {
    setCursorPosition(e.currentTarget.selectionStart);
  };

  const handleTextareaKeyUp = (e: React.KeyboardEvent<HTMLTextAreaElement>) => {
    setCursorPosition(e.currentTarget.selectionStart);
  };

  const checkText = async () => {
    setError('');
    try {
      const response = await fetch('/api/check-text', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ text }),
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data: TermsFoundResponse = await response.json();
      setResults(data);
    } catch (e) {
      setError('Failed to check the text');
    }
  };

  const highlightTerms = (text: string, terms: { [key: string]: number[] }, cursorPos: number): JSX.Element[] => {
    let lastIndex = 0;
    const highlightedText: JSX.Element[] = [];
    let cursorPlaced = false;

    // Sort terms by positions before rendering
    const sortedTerms = Object.entries(terms).sort((a, b) => a[1][0] - b[1][0]);

    sortedTerms.forEach(([term, positions]) => {
      positions.forEach(position => {
        // Text before the term
        if (position > lastIndex) {
          // Check if cursor should be placed before this term
          if (!cursorPlaced && cursorPos >= lastIndex && cursorPos < position) {
            highlightedText.push(<span key={`text-before-cursor-${lastIndex}`}>{text.slice(lastIndex, cursorPos)}</span>);
            highlightedText.push(<span key="cursor-indicator" className="cursor-indicator">|</span>);
            highlightedText.push(<span key={`text-after-cursor-${cursorPos}`}>{text.slice(cursorPos, position)}</span>);
            cursorPlaced = true;
          } else {
            highlightedText.push(<span key={`text-before-${term}-${position}`}>{text.slice(lastIndex, position)}</span>);
          }
        }
        // The term itself
        highlightedText.push(<mark key={`${term}-${position}`}>{term}</mark>);
        lastIndex = position + term.length;
      });
    });

    // Text after the last term or cursor
    if (text.length > lastIndex) {
      if (!cursorPlaced && cursorPos >= lastIndex) {
        highlightedText.push(<span key={`text-before-cursor-end`}>{text.slice(lastIndex, cursorPos)}</span>);
        highlightedText.push(<span key="cursor-indicator-end" className="cursor-indicator">|</span>);
        highlightedText.push(<span key={`text-after-cursor-end`}>{text.slice(cursorPos)}</span>);
      } else {
        highlightedText.push(<span key={`text-after-last-term`}>{text.slice(lastIndex)}</span>);
      }
    } else if (!cursorPlaced && cursorPos === text.length) {
      highlightedText.push(<span key="cursor-indicator-end" className="cursor-indicator">|</span>);
    }

    return highlightedText;
  };

  return (
    <div className="container">
      <h1 className="title">China Words Checker</h1>
      <textarea
        className="input-text"
        value={text}
        onChange={handleTextareaChange}
        onClick={handleTextareaClick}
        onKeyUp={handleTextareaKeyUp}
        placeholder="Type or paste text here..."
      />
      <button className="check-button" onClick={checkText}>Check Text</button>
      <div className="highlighted-text">
        {highlightTerms(text, results.terms, cursorPosition)}
      </div>
    </div>
  );
};

export default CheckerPage;
