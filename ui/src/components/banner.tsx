/**
* This code was generated by v0 by Vercel.
* @see https://v0.dev/t/lh7Gq3XMCV1
* Documentation: https://v0.dev/docs#integrating-generated-code-into-your-nextjs-app
*/

/** Add fonts into your Next.js project:

import { Inter } from 'next/font/google'

inter({
  subsets: ['latin'],
  display: 'swap',
})

To read more about using these font, please visit the Next.js documentation:
- App Directory: https://nextjs.org/docs/app/building-your-application/optimizing/fonts
- Pages Directory: https://nextjs.org/docs/pages/building-your-application/optimizing/fonts
**/
export function Banner() {
  return (
    <div className="bg-primary text-primary-foreground py-4 px-6 flex items-center justify-between" style={{backgroundColor: 'rgb(37, 99, 235)'}}>
      <div className="flex items-center gap-4">
        <div className="bg-primary-foreground rounded-full w-10 h-10 flex items-center justify-center" style={{borderRadius: '50%'}}>
          <PlaneIcon className="w-6 h-6 text-primary" />
        </div>
        <div className="font-bold text-2xl">Aviato</div>
      </div>
      <div className="text-lg font-medium">Your AI Travel Agent</div>
    </div>
  )
}

function PlaneIcon(props:any) {
  return (
    <svg
      {...props}
      xmlns="http://www.w3.org/2000/svg"
      width="24"
      height="24"
      viewBox="0 0 24 24"
      fill="none"
      stroke="rgb(37, 99, 235)"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <path d="M17.8 19.2 16 11l3.5-3.5C21 6 21.5 4 21 3c-1-.5-3 0-4.5 1.5L13 8 4.8 6.2c-.5-.1-.9.1-1.1.5l-.3.5c-.2.5-.1 1 .3 1.3L9 12l-2 3H4l-1 1 3 2 2 3 1-1v-3l3-2 3.5 5.3c.3.4.8.5 1.3.3l.5-.2c.4-.3.6-.7.5-1.2z" />
    </svg>
  )
}
