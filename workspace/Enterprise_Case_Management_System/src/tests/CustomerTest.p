/* Customer module end-to-end test */

RUN customer/CustomerCreate.p (
    4,
    "John",
    "Smith",
    "john.smith@example.com",
    "5735559876",
    DATE(5, 15, 1992),
    "Active"
).

RUN customer/CustomerRead.p (
    4
).

RUN customer/CustomerUpdate.p (
    4,
    "John",
    "Williams",
    "john.williams@example.com",
    "5735559876",
    "Active"
).

RUN customer/CustomerRead.p (
    4
).

RUN customer/CustomerDelete.p (
    4
).

RUN customer/CustomerRead.p (
    4
).