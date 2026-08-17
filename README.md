# z-Commerce

A demo shop where the customer proves they are old enough to buy an age-restricted
product **without revealing their date of birth**. The proof is a zero-knowledge range
proof: the shop learns only that the birth date is earlier than a threshold, nothing else.

The delivery service repeats the check on its own, against the same credential, so the
courier does not have to trust the shop's word — or see the customer's data either.

## How a purchase works

1. The customer fills a cart on the storefront and starts the checkout.
2. At the age step the controller creates an order and issues a connection invitation.
3. The wallet holds a credential issued to the customer by a trusted authority. It builds
   a range proof over the birth date attribute and sends the proof — not the attribute.
4. The verifier checks the proof against the issuer's public key and the order's challenge.
5. On handover the delivery service runs the same verification through its own verifier.

## Components

| Folder | What it does |
| --- | --- |
| `z-commerce-storefront` | Shop front end, Next.js on top of the Medusa storefront |
| `z-commerce-medusa` | Shop backend — catalogue, cart, orders, admin panel |
| `z-commerce-heimdall` | Zero-knowledge engine — credentials, proofs, verification (circom + snarkjs) |
| `z-commerce-wallet` | The customer's wallet (Expo) — stores the credential, produces proofs |
| `z-commerce-controller` | Checkout orchestration — orders, invitations, verification requests |
| `z-commerce-socket` | WebSocket relays between the front ends and the controller |
| `z-commerce-delivery` | Delivery front end with its own independent verifier |

Heimdall runs as five separate instances, one per role: certificate authority, issuer,
holder, verifier, and a second verifier for the delivery service.

## Requirements

Docker with Compose, and patience for the first build: heimdall compiles circom from
source, so expect a long build and roughly 30 GB of disk for the images.

## Getting started

```shell
git clone --recurse-submodules https://github.com/ermolaev1337/z-commerce.git
cd z-commerce
sh start.sh
```

`start.sh` builds and starts every service in dependency order. The Medusa database is
seeded automatically on the first run only.

## Checking that it works

Open the storefront at [http://localhost](http://localhost) and walk through a purchase:

1. Add an age-restricted item to the cart and go to the checkout.
2. When the checkout asks for a proof of age, open the wallet at
   [http://localhost:19006](http://localhost:19006) and connect it to the order.
3. The wallet builds the proof; the age step on the storefront closes by itself and the
   order can be submitted.
4. Follow the order into the delivery service at
   [http://localhost:1337](http://localhost:1337), which verifies the proof again.

The admin panel is at [http://localhost:9000/app](http://localhost:9000/app), with the
login `admin@medusa-test.com` and the password `supersecret`.

## Ports

| Service | Port |
| --- | --- |
| Storefront | 80 |
| Medusa backend and admin panel | 9000 |
| Delivery front end | 1337 |
| Wallet — front end / backend | 19006 / 8286 |
| Controller — shop / delivery | 2222 / 12222 |
| Heimdall — CA, issuer, holder, verifier, delivery verifier | 8081–8085 |
| Sockets — shop / delivery | 17777, 18888 / 27777, 28888 |
| Mongo Express — shop / delivery | 8381 / 8481 |

## Troubleshooting

**The build takes forever.** Heimdall builds circom from source with cargo. This is
expected on a first run; later builds reuse the Docker layer cache.

**Containers of other projects disappeared.** Older revisions of `start.sh` removed every
container on the machine, not just this project's. It no longer does; if you kept a local
copy of the old script, check its first lines.

**Heimdall fails to build the Go helper on Apple silicon.** Replace
`RUN go install github.com/msoap/shell2http@latest` with
`RUN go get github.com/msoap/shell2http@latest` in `z-commerce-heimdall/Dockerfile`.

**The storefront build fails with connection errors.** The Next.js build pre-renders pages
against a running Medusa backend. Start Medusa first, or just use `start.sh`, which
already orders the services correctly.

## Configuration

Each service reads its own environment file, kept next to its compose file. Copy the
examples and adjust if you run the stack somewhere other than localhost. The heimdall
credential registry needs a GitHub token with write access to the revocation repository;
leave `GITHUB_TOKEN` empty to run the demo without credential revocation.
