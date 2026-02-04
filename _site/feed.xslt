<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:atom="http://www.w3.org/2005/Atom">
  <xsl:output method="html" encoding="UTF-8" indent="yes"/>

  <xsl:template match="/">
    <html lang="en">
      <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title><xsl:value-of select="atom:feed/atom:title"/> - RSS Feed</title>
        <style>
          * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
          }
          body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            line-height: 1.6;
            color: #1a1a1a;
            background: #fafafa;
            padding: 2rem;
            max-width: 720px;
            margin: 0 auto;
          }
          .header {
            margin-bottom: 2rem;
            padding-bottom: 1.5rem;
            border-bottom: 1px solid #e5e5e5;
          }
          .header h1 {
            font-size: 1.5rem;
            font-weight: 600;
            margin-bottom: 0.25rem;
          }
          .header p {
            color: #666;
            font-size: 0.9rem;
          }
          .notice {
            background: #fff8e6;
            border: 1px solid #ffe066;
            border-radius: 6px;
            padding: 1rem;
            margin-bottom: 2rem;
            font-size: 0.875rem;
          }
          .notice strong {
            display: block;
            margin-bottom: 0.25rem;
          }
          .notice code {
            background: #fff;
            padding: 0.125rem 0.375rem;
            border-radius: 3px;
            font-size: 0.8rem;
          }
          .entries {
            list-style: none;
          }
          .entry {
            background: #fff;
            border: 1px solid #e5e5e5;
            border-radius: 8px;
            padding: 1.25rem;
            margin-bottom: 1rem;
          }
          .entry h2 {
            font-size: 1.1rem;
            font-weight: 600;
            margin-bottom: 0.5rem;
          }
          .entry h2 a {
            color: #1a1a1a;
            text-decoration: none;
          }
          .entry h2 a:hover {
            color: #0066cc;
          }
          .entry .date {
            font-size: 0.8rem;
            color: #999;
            margin-bottom: 0.5rem;
          }
          .entry .summary {
            font-size: 0.9rem;
            color: #444;
          }
          @media (prefers-color-scheme: dark) {
            body {
              background: #0a0a0a;
              color: #e5e5e5;
            }
            .header {
              border-color: #282828;
            }
            .notice {
              background: #1a1a00;
              border-color: #4d4d00;
            }
            .notice code {
              background: #282828;
            }
            .entry {
              background: #161616;
              border-color: #282828;
            }
            .entry h2 a {
              color: #e5e5e5;
            }
            .entry h2 a:hover {
              color: #66b3ff;
            }
            .entry .summary {
              color: #999;
            }
          }
        </style>
      </head>
      <body>
        <div class="header">
          <h1><xsl:value-of select="atom:feed/atom:title"/></h1>
          <p><xsl:value-of select="atom:feed/atom:subtitle"/></p>
        </div>

        <div class="notice">
          <strong>This is an RSS feed</strong>
          Subscribe by copying this URL into your feed reader: <code><xsl:value-of select="atom:feed/atom:link[@rel='self']/@href"/></code>
        </div>

        <ul class="entries">
          <xsl:for-each select="atom:feed/atom:entry">
            <li class="entry">
              <h2>
                <a>
                  <xsl:attribute name="href">
                    <xsl:value-of select="atom:link/@href"/>
                  </xsl:attribute>
                  <xsl:value-of select="atom:title"/>
                </a>
              </h2>
              <div class="date">
                <xsl:value-of select="substring(atom:published, 1, 10)"/>
              </div>
              <p class="summary">
                <xsl:value-of select="atom:summary"/>
              </p>
            </li>
          </xsl:for-each>
        </ul>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
