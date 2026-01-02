"use client";

import { ThemeProvider } from "@mui/material/styles";
import CssBaseline from "@mui/material/CssBaseline";
import Container from "@mui/material/Container";
import theme from "./theme";
import "./globals.css";

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>
        <ThemeProvider theme={theme}>
          <CssBaseline />
          <Container
            component="main"
            sx={{
              minHeight: "100vh",
              display: "flex",
              flexDirection: "column",
              py: 4,
            }}
          >
            {children}
          </Container>
        </ThemeProvider>
      </body>
    </html>
  );
}
