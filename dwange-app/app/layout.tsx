import type { Metadata } from "next";
import { IBM_Plex_Sans_Arabic } from "next/font/google";
import "./globals.css";

const ibmPlexSansArabic = IBM_Plex_Sans_Arabic({
  weight: ["300", "400", "500", "600", "700"],
  variable: "--font-ibm-plex-sans-arabic",
  subsets: ["latin", "arabic"],
});

export const metadata: Metadata = {
  title: "Dwange",
  description:
    "A platform to share, discuss, and explore a wide range of topics.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="">
      <body
        className={`${ibmPlexSansArabic.className} antialiased dark bg-background text-foreground`}
      >
        {children}
      </body>
    </html>
  );
}
