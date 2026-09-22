import createClient, { type Client } from "openapi-fetch";
import type { paths } from "../../generated/schema";

const CLIENT_IDENTITY: string =
  'Client="jellarr", Device="cli", DeviceId="jellarr", Version="0.1.0"';

export function makeClient(baseUrl: string, apiKey?: string): Client<paths> {
  const client: Client<paths> = createClient<paths>({
    baseUrl: baseUrl.replace(/\/+$/, ""),
  });

  client.use({
    onRequest({ request }: { request: Request }): Request {
      const headers: Headers = new Headers(request.headers);
      // The startup wizard runs before an API key exists, so the token is
      // omitted rather than sent as "undefined" -- /Startup/* accepts an
      // unauthenticated client as long as it identifies itself.
      headers.set(
        "Authorization",
        apiKey
          ? `MediaBrowser Token="${apiKey}", ${CLIENT_IDENTITY}`
          : `MediaBrowser ${CLIENT_IDENTITY}`,
      );
      return new Request(request, { headers });
    },
  });

  return client;
}
