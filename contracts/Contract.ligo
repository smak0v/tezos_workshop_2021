type storage is record[
  functionCalled: bool;
  admin: address;
  n1: nat;
  n2: nat;
]

type return is list(operation) * storage

type actions is
| SendRequest of address
| HandleCallback of nat*nat

const noOperations : list(operation) = nil;

function sendRequest(const value : address; const s : storage) : return is
block {
  if Tezos.sender =/= s.admin then failwith("Allowed only for admin") else skip;
  if s.functionCalled then failwith("Already called") else skip;

  var callee : contract(contract(nat*nat)) := nil;

  case (Tezos.get_entrypoint_opt("%get_info", value) : option(contract(contract(nat*nat)))) of
  | None -> failwith("Callee not found")
  | Some(c) -> callee := c
  end;

  var param : contract(nat*nat) := nil;

  case (Tezos.get_entrypoint_opt("%handleCallback", Tezos.self_address) : option(contract(nat*nat))) of
  | None -> failwith("Callback function not found")
  | Some(p) -> param := p
  end;

  const response : list(operation) = list [Tezos.transaction(param, 0mutez, callee)];

  s.functionCalled := True;
} with (response, s)

function handleCallback(const n1 : nat; const n2 : nat; const s : storage) : return is
block {
  s.n1 := n1;
  if n2 mod 2 = 0n then s.n2 := 33n else s.n2 := n2;
} with (noOperations, s)

function main(const action : actions; const s : storage) : return is
case action of
| SendRequest(v) -> sendRequest(v, s)
| HandleCallback(v) -> handleCallback(v.0, v.1, s)
end
